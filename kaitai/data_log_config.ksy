meta:
  id: data_log_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8dff0
  # - size: 0x5ea5e

  - type: u1
    valid: 1

  - id: marker
    type: u4
    valid: 0x83

  - id: num_data_log
    type: u4

  - id: data_log_data
    type: data_log_data
    # size: 36
    repeat: expr
    repeat-expr: num_data_log


types:
  data_log_data:
    seq:
      - id: marker
        type: u1
        valid: 3

      - id: enabled
        type: u4

      - id: index
        type: u4

      - id: memory_allocation_offset
        type: u4

      - id: name
        type: smart_types::strl

      - id: flag
        type: u1
        valid: 1

      - id: flag_2
        type: u4
        valid: 1

      - id: flag_3
        type: u4
        valid: 1

      - id: flag_4
        type: u4
        valid: 0

      - id: num_max_records
        type: u4

      - id: num_definition
        type: u4

      - id: definition
        type: definition
        repeat: expr
        repeat-expr: num_definition


  definition:
    seq:
      - id: marker
        type: u1

      - id: name
        type: smart_types::strl

      - id: data_type
        type: u4
        # 04 00 00 00: byte
        # 00 10 00 00: real

      - id: comment
        type: smart_types::strl


