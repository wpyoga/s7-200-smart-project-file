meta:
  id: pto_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x2c336

  - type: u2
    valid: 0x84

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
  - type: u4
  - type: u4

  - id: motor_speed_max
    type: f8

  - id: motor_speed_min
    type: f8

  - type: f8

  - type: u4

  - type: u4
  - id: accel_time_ms
    type: u4

  - id: decel_time_ms
    type: u4

  - type: u4

  - type: u1

  - id: ctrl_pou
    type: smart_types::strl

  - id: man_pou
    type: smart_types::strl

  - id: run_pou
    type: smart_types::strl

  - id: ldpos_pou
    type: smart_types::strl

  - id: afv_pou
    type: smart_types::strl

  - type: u4

  - type: u2
  - type: u2

  - type: u4

  - type: u1
































































