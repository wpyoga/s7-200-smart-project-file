meta:
  id: smart_project
  title: MicroWIN SMART decompressed project data
  endian: le
  imports:
    - preamble
    - system_block

seq:
  # Versioning
  - id: preamble
    type: preamble

  - id: timestamp1
    type: smart_types::timestamp

  - id: timestamp2
    type: smart_types::timestamp

  - type: u1

  - id: timestamp3
    type: smart_types::timestamp

  - id: timestamp4
    type: smart_types::timestamp

  - id: system_block
    type: system_block

  # - id: program_block
  #   type: program_block

  # - id: cpu_information
  #   type: cpu_info

types:

  placeholder:
    seq:
      - type: u4





