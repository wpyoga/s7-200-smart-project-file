meta:
  id: pid_config_mwp
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x2ce54
  # - size: 0x2ccaf

  - id: marker
    type: u2
    valid: 0x02

  - id: marker_2
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

  - type: u1
    valid: 2

  - id: index
    type: u4

  - type: u1
    valid: 1

  - id: sp_high
    type: f4

  - id: sp_low
    type: f4

  - id: sample_time
    type: f4

  - size: 20

  - id: digital_duty_cycle_time_s
    type: f4

  - id: pv_low
    type: s4

  - id: pv_high
    type: s4

  - id: analog_out_low_range
    type: f4

  - id: analog_out_high_range
    type: f4

  - id: enable_alarm_pv_low
    type: u1

  - id: alarm_pv_low
    type: f4

  - id: enable_alarm_pv_high
    type: u1

  - id: alarm_pv_high
    type: f4

  - id: enable_analog_input_module_error
    type: u1

  - id: analog_input_module_pos
    type: u2

  - type: u1

  - id: pid_init_pou
    type: smart_types::strl1

  - id: pid_exe_pou
    type: smart_types::strl1

  - size: 10
  - type: f4
  - type: u2
  - type: u2
  - type: f4
  - type: smart_types::nulls(11)

  - type: f4
  - type: f4

  - type: u4

  - type: f4
  - type: u4
  - type: f4
  - type: f4
  - type: f4
  - type: u4
  - type: u1
  - type: u4
































