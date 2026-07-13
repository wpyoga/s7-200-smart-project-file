meta:
  id: asi_config
  endian: le
  imports:
    - smart_types

seq:
  - type: u4

  - type: u1
    # valid: 2

  - id: maybe_crc
    type: u4

  - type: u1

  - size: 11
    repeat: expr
    repeat-expr: 6

  - type: u4
    repeat: expr
    repeat-expr: 6

  - id: ctrl_pou
    type: smart_types::strl

  - id: write_pou
    type: smart_types::strl

  - id: read_pou
    type: smart_types::strl

  - type: smart_types::nulls(5)

































