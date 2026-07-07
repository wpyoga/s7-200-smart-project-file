meta:
  id: unknown_data60
  endian: le
  imports:
    - smart_types

seq:
  # unknown block 7

  - type: u1
    valid: 1

  - type: u4
    valid: 0x83

  - id: num_records_5
    type: u4

  - id: unknown_records_5
    size: 36
    repeat: expr
    repeat-expr: num_records_5

