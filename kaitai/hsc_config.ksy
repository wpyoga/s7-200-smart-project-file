meta:
  id: hsc_config
  endian: le
  imports:
    - smart_types

seq:
  # unknown block 3 (HSC)

  - type: u1
    valid: 4

  - type: u4
    valid: 4

  - id: num_hsc
    type: u4

  - id: hsc_data
    size: 120
    repeat: expr
    repeat-expr: num_hsc

