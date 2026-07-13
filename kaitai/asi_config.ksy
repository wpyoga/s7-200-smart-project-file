meta:
  id: asi_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x2c689

  - type: u2
    valid: 0x40

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

































