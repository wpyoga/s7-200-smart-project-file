meta:
  id: unknown_data20
  endian: le
  imports:
    - smart_types

seq:
  # unknown block 1

  - type: u1
    valid: 1

  - type: smart_types::nulls(4)

  - id: version
    type: u1
    # 3: v2.x
    # 1: v1.x

  - size: 8
    if: version == 3

  - id: num_records
    type: u4

  - id: unknown_records_v2
    type: unknown_records_v2
    size: 715
    if: version == 3
    repeat: expr
    repeat-expr: num_records

  - id: unknown_records_v1
    type: unknown_records_v1
    size: 562
    if: version == 1
    repeat: expr
    repeat-expr: num_records


types:
  unknown_records_v2:
    seq:
      - type: u2
        valid: 0x0104

      - type: smart_types::nulls(8)

      - id: version
        type: u1
        # 2: v2.x
        # 1: v1.x

      - type: smart_types::nulls(4)

      - type: u2
        valid: 2

      - type: u2
        valid: 0x6d63

      - id: marker
        type: u2
        valid: 0x1388

      - type:
          switch-on: version
          cases:
            2: smart_types::nulls(8)
            1: smart_types::nulls(4)


  unknown_records_v1:
    seq:
      - type: u1

