meta:
  id: td_config_mwp
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x2bfea

  - type: u2
    valid: 0x01

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

  - type: u2
  - type: u2
  - type: u1
  - type: u1
  - type: u1
  - type: u1
  - type: u1
  - type: u1
  - type: u1
  - type: u1

  - size: 93

  - id: alarm_pou
    type: smart_types::strl

  - id: ctrl_pou
    type: smart_types::strl

  - type: u2
  - type: u1

  - id: shift_key
    type: smart_types::strl

  - id: num_key
    type: u1

  - type: u4

  - id: key
    type: key
    repeat: expr
    repeat-expr: num_key
    # repeat-expr: 3




types:
  key:
    seq:
      - id: index
        type: u4

      - id: shift
        type: u1

      # - type: u4

      - id: name
        type: smart_types::strl

      - id: name_abbrev
        type: smart_types::strl

      - type: u2
      - type: u4
      - type: u4
      - type: u4
      - type: u4
      - type: u4
      - type: u1






























