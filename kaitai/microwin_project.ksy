meta:
  id: microwin_project
  title: Micro/WIN decompressed project data
  endian: le
  imports:
    - smart_types
    - preamble
    - system_block_mwp
    - program_block
    - symbol_table
    - status_chart
    - data_block
    - cpu_information
    - unknown_data10
    - motion_config
    - pid_config
    - hsc_config
    - pwm_config
    - td_config
    - get_put_config
    - data_log_config

seq:
  - id: preamble
    type: preamble

  - id: timestamp1a
    type: smart_types::timestamp

  - id: timestamp1b
    type: smart_types::timestamp

  - type: u1
    valid: 0x01

  # TODO: consider whether these timestamps are
  #       part of the system block
  #       maybe also the preceding 0x01 marker
  - id: timestamp1c
    type: smart_types::timestamp
    if: preamble.editor_version >= 0x10

  - id: timestamp1d
    type: smart_types::timestamp
    if: preamble.editor_version >= 0x10

  - id: system_block
    type:
      switch-on: preamble.editor_version
      cases:
        0x1c: system_block
        0x1b: system_block
        0x1a: system_block
        0x18: system_block
        0x12: system_block
        0x10: system_block_mwp
        0x0a: system_block_mwp  # maybe use v3?

  - type: u1
    # this is sometimes 1 and sometimes 0
    # not related to version -- not sure what this is

  - id: timestamp2a
    type: smart_types::timestamp

  - id: timestamp2b
    type: smart_types::timestamp

  - id: timestamp2c
    type: smart_types::timestamp

  - id: timestamp2d
    type: smart_types::timestamp

  - id: program_block
    type: program_block

  - id: symbol_table
    type: symbol_table

  - id: status_chart
    type: status_chart

  - id: data_block
    type: data_block

  - id: cpu_information
    type: cpu_information

  - id: unknown_data10
    type: unknown_data10


  # looks like the configs do not have fixed position
  # might be based on magic number

  - id: td_config
    type: td_config

  - id: motion_config
    type: motion_config

  - id: modem_config
    type: modem_config

  - id: eth_config
    type: eth_config

  - id: asi_config
    type: asi_config

  - id: internet_config
    type: internet_config

  - id: pid_config
    type: pid_config

  - id: netr_netw_config
    type: netr_netw_config

  - id: project_info
    type: project_info






  - id: hsc_config
    type: hsc_config

  - id: pwm_config
    type: pwm_config

  - id: data_log_config
    type: data_log_config
