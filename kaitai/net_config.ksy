meta:
  id: net_config
  endian: le
  imports:
    - smart_types

seq:
  - type: u1
    valid: 2

  - id: index
    type: u4

  - id: net_exe_pou
    type: smart_types::strl1


  - type: u4
    valid: 1

  - type: u2
    valid: 1

  - id: remote_plc_address
    type: u4

  - id: bytes_to_read
    type: u4

  - type: u2
    valid: 2

  - id: local_plc_address_type
    type: u2
    valid: 0x1002
    # 02 10: VB

  - type: smart_types::nulls(3)

  - id: local_plc_store_address
    type: u4

  - type: u2
    valid: 2

  - id: remote_plc_address_type
    type: u2
    valid: 0x1002
    # 02 10: VB

  - type: smart_types::nulls(3)

  - id: remote_plc_read_address
    type: u4

  - size: 11
    repeat: expr
    repeat-expr: 2

  - type: u4
    valid: 0

  - type: u1
    valid: 1

  - type: u4
    valid: 0

  - type: u4
    valid: 4

  - type: u4
    valid: 0











