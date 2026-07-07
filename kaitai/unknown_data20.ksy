meta:
  id: unknown_data20
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8bf4d

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

      - id: some_attr
        type: u1
        # f0: v2.x
        # 80: v1.x

      - id: some_attr_2
        type: u1
        valid: 0x3f

      - id: some_records_v2
        size: 25
        repeat: expr
        repeat-expr: 7
        if: version == 2

      - id: some_records_v1
        size: 21
        repeat: expr
        repeat-expr: 6
        if: version == 1

      - id: some_record_2_v2
        size: 10
        if: version == 2

      - id: some_record_2_v1
        size: 6
        if: version == 1

      - id: some_record_3_v2
        size: 21
        if: version == 2

      - id: some_record_3_v1
        size: 9
        if: version == 1

      - type: smart_types::nulls(2)

      - id: some_attr_copy
        type: u1
        valid: some_attr

      - id: some_attr_2_copy
        type: u1
        valid: some_attr_2

      - type: u1
        valid: 1

      - id: marker_2
        type: u4
        valid: 0x03e8

      - id: marker_2_copy
        type: u4
        valid: marker_2

      - id: some_record_4_v2
        size: 28
        if: version == 2

      - id: some_record_4_v1
        size: 20
        if: version == 1

      - id: some_record_5_v2
        size: 113
        if: version == 2

      - id: some_record_5_v1
        size: 37
        if: version == 1

      - type: smart_types::nulls(16)

      - id: some_records_2
        size: 11
        repeat: expr
        repeat-expr: 28





  unknown_records_v1:
    seq:
      - type: u1











































