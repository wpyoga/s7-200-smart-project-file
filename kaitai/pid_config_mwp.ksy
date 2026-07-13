meta:
  id: pid_config_mwp
  endian: le
  imports:
    - smart_types

seq:
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
































