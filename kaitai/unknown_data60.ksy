meta:
  id: unknown_data60
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8dff0

  - type: u1
    valid: 1

  - id: marker
    type: u4
    valid: 0x83

  - id: num_record
    type: u4

  - id: unknown_record
    type: unknown_record
    size: 36
    repeat: expr
    repeat-expr: num_record


types:
  unknown_record:
    seq:
      - type: u1
        valid: 3

      - type: smart_types::nulls(4)

      - id: index
        type: u4

      - type: smart_types::nulls(6)

      - type: u1
        valid: 1

      - type: u4
        valid: 1

      - type: u4
        valid: 1

      - type: u4
        valid: 0

      - type: u2
        valid: 0x03e8

      - type: smart_types::nulls(6)













































