meta:
  id: unknown_data40
  endian: le
  imports:
    - smart_types

seq:
  # unknown block 5

  - type: u1
    valid: 2

  - id: num_records_3
    type: u4

  - id: unknown_records_3
    size: 442
    repeat: expr
    repeat-expr: num_records_3


