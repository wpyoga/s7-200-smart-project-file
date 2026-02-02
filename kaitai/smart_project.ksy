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
    # - data_block

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

  # - id: data_block
  #   type: data_block






