meta:
  id: unknown_data30
  endian: le
  imports:
    - smart_types

seq:
  # unknown block 4

  - type: u1
    valid: 1

  - id: num_records_2
    type: u4

  - id: unknown_records_2
    size: 59
    repeat: expr
    repeat-expr: num_records_2

