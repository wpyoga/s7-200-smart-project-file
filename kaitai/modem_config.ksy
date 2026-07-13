meta:
  id: modem_config
  endian: le
  imports:
    - smart_types

seq:
  - id: index
    type: u2

  - type: u2

  - type: u1
    # valid: 2

  - id: module_command_byte
    type: u4

  - type: u1
  - type: u1

  - id: ctrl_pou
    type: smart_types::strl

  - id: xfr_pou
    type: smart_types::strl

  - id: cfg_pou
    type: smart_types::strl

  - type: smart_types::nulls(1)










































