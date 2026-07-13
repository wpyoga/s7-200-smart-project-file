meta:
  id: eth_config
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

  - id: keep_alive_interval_s
    type: u4

  - type: u1
  - type: u2

  - id: ip_address
    type: smart_types::ipv4_addr

  - id: subnet_mask
    type: smart_types::ipv4_addr

  - id: gateway
    type: smart_types::ipv4_addr

  - id: ctrl_pou
    type: smart_types::strl

  - id: xfr_pou
    type: smart_types::strl

  - id: cfg_pou
    type: smart_types::strl

  - type: smart_types::nulls(5)










































