meta:
  id: unknown_data30
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8d62c
  # - size: 0x1bcf89

  - type: u1
    valid: 1

  - id: num_record
    type: u4

  - id: unknown_record
    type: unknown_record
    # size: 59
    repeat: expr
    repeat-expr: num_record


types:
  unknown_record:
    seq:
      - type: u1

      - type: smart_types::nulls(4)

      - id: index
        type: u2

      - type: smart_types::nulls(2)

      - id: pwm_name
        type: smart_types::strl

      - type: u4
        valid: 1

      - id: some_record_2
        type: some_record_2
        repeat: expr
        repeat-expr: 4

  some_record_2:
    seq:
      - type: u1
        valid: 2

      - type: u1
        valid: 3

      - type: u1
        valid: 0x40

      - type: smart_types::nulls(8)










































