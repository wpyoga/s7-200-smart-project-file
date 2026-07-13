meta:
  id: internet_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x2c767

  - type: u2
    valid: 0x81

  - type: u1
    valid: 5

  - id: description
    type: smart_types::strl

  - id: data_page_name
    type: smart_types::strl

  - id: symbol_table_name
    type: smart_types::strl

  - type: u2
    valid: 2

  - id: memory_allocation_offset_address_type
    type: u2
    valid: 0x1002
    # 02 10: VB

  - type: smart_types::nulls(3)

  - id: memory_allocation_offset
    type: u4

  - id: timestamp1
    type: smart_types::timestamp

  - id: timestamp2
    type: smart_types::timestamp

  - type: u1
    # valid: 2

  - id: index
    type: u4

  - id: module_command_byte
    type: u4

  - type: u1

  - id: keep_alive_interval_s
    type: u4

  - type: u1

  - type: u2
    valid: 1

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

  - type: u4

  - id: maybe_enable_email
    type: u1

  - id: email_pou
    type: smart_types::strl

  - id: ftp_client_pou
    type: smart_types::strl

  - size: 8
    repeat: expr
    repeat-expr: 47

  - size: 22
    repeat: expr
    repeat-expr: 32

  - id: admin_id
    type: smart_types::strl

  - id: password
    type: smart_types::strl

  - size: 75
























