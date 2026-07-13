meta:
  id: pos_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x2c410

  - type: u2
    valid: 0x10

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

  - id: module_number
    type: u1

  - type: u2

  - type: u1
    # valid: 2

  - id: module_command_byte
    type: u4

  - type: u1
  - type: u1

  - id: pulses_per_motor_revolution
    type: u4

  - id: unit_of_measurement
    type: smart_types::strl

  - id: units_of_motion_per_motor_revolution
    type: f4

  - id: motor_speed_start_stop
    type: f8

  - id: motor_speed_max
    type: f8

  - id: jog_speed
    type: f8

  - id: jog_increment
    type: f8

  - id: accel_time_ms
    type: u4

  - id: decel_time_ms
    type: u4

  - id: jerk_time_ms
    type: u4

  - type: u1
    valid: 1

  - id: ctrl_pou
    type: smart_types::strl

  - id: man_pou
    type: smart_types::strl

  - id: run_pou
    type: smart_types::strl

  - id: srate_pou
    type: smart_types::strl

  - id: goto_pou
    type: smart_types::strl

  - id: dis_pou
    type: smart_types::strl

  - id: ldoff_pou
    type: smart_types::strl

  - id: ldpos_pou
    type: smart_types::strl

  - id: rseek_pou
    type: smart_types::strl

  - id: clr_pou
    type: smart_types::strl

  - id: cfg_pou
    type: smart_types::strl

  - type: u4

  - type: u4

  - type: u2

  - type: u1
  - type: u1
  - type: u1
  - type: u1
  - type: u2
  - type: u2
  - type: u2

  - type: u4
  - type: u4

  - id: rp_fast_mm_s
    type: f4

  - id: rp_slow_mm_s
    type: f4

  - id: backlash_compensation_mm
    type: f4

  - type: u2
  - type: u4
  - id: rp_offset_mm
    type: f4

  - type: u4
  - type: u1
  - type: u4












































