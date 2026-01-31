meta:
  id: smart_project
  title: MicroWIN SMART decompressed project data
  endian: le
  imports:
    - smart_types
    - preamble
    - system_block
    - program_block


seq:
  # Versioning
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

  # - type: u1

  # - id: cpu_information
  #   type: cpu_info

types:

  placeholder:
    seq:
      - type: u4















