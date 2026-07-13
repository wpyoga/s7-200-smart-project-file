meta:
  id: wizard_data
  endian: le
  imports:
    - smart_types
    - td_config_mwp
    - pid_config_mwp
    - net_config
    - pos_config
    - modem_config
    - asi_config
    - eth_config
    - internet_config
    - pto_config


seq:
  # - size: 0x2bfe5

  - id: num_config
    type: u4

  - type: u1
    valid: 0

  - id: config
    type: config
    repeat: expr
    repeat-expr: num_config


types:
  config:
    seq:
      - id: wizard_id
        type: u2
        valid:
          any-of: [0x01, 0x02, 0x08, 0x10, 0x20, 0x40, 0x80, 0x81, 0x84]

      - id: version
        type: u1
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

      - id: config_data
        type:
          switch-on: wizard_id
          cases:
            0x01: td_config_mwp
            0x02: pid_config_mwp
            0x08: net_config
            0x10: pos_config
            0x20: modem_config
            0x40: asi_config
            0x80: eth_config
            0x81: internet_config
            0x84: pto_config









































