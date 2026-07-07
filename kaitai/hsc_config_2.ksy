meta:
  id: hsc_config_2
  endian: le
  imports:
    - smart_types

seq:
  # hsc block #2

  - type: u1
    valid: 4

  - type: u4
    valid: 4

  - id: num_hsc_2
    type: u4

  - id: hsc_data_2
    size: 128
    repeat: expr
    repeat-expr: num_hsc_2
