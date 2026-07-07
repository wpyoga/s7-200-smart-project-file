meta:
  id: smart_project
  title: MicroWIN SMART decompressed project data
  endian: le
  imports:
    - smart_types
    - preamble
    - system_block
    - program_block
    - symbol_table
    - status_chart
    - data_block
    - cpu_information
    - unknown_data10
    - unknown_data20
    - pid_config
    - hsc_config
    - unknown_data30
    - unknown_data40
    - unknown_data50
    - unknown_data60
    - profinet_config
    - hsc_config_2
    - unknown_data70

seq:
  - id: preamble
    type: preamble

  - id: timestamp1a
    type: smart_types::timestamp

  - id: timestamp1b
    type: smart_types::timestamp

  - type: u1
    valid: 0x01

  - id: timestamp1c
    type: smart_types::timestamp

  - id: timestamp1d
    type: smart_types::timestamp

  - id: system_block
    type: system_block

  - type: u1
    # this is 1 for R02.04.00.00 and R03.01.00.00
    #   and also for R04.00 (MWP)
    # this is 0 for R01.00.00.00

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

  - id: unknown_data20
    type: unknown_data20

  - id: pid_config
    type: pid_config

  - id: hsc_config
    type: hsc_config

  - id: unknown_data30
    type: unknown_data30

  - id: unknown_data40
    type: unknown_data40
    # looks like TD200 text display config

  - id: unknown_data50
    type: unknown_data50

  - id: unknown_data60
    type: unknown_data60

  - id: profinet_config
    type: profinet_config

  - id: hsc_config_2
    type: hsc_config_2

  - id: unknown_data70
    type: unknown_data70





