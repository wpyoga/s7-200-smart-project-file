meta:
  id: pid_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8ca8b
  # - size: 0x43380
  # - size: 0x58826
  # - size: 0x58c75
  # - size: 0x3c882
  # - size: 0x9082
  # - size: 0x9f14

  - type: u1
    valid: 1

  - id: num_pid
    type: u4

  - id: pid_data
    type: pid_data
    repeat: expr
    repeat-expr: num_pid

  - id: pid_int_pou_name
    type: smart_types::strl

  # - size: 38

  - type: u2
    valid: 2
    repeat: expr
    repeat-expr: 3

  - type: smart_types::null1

  - type: u4
    valid: 0x22

  - id: version
    type: u1

  - type: smart_types::nulls(6)

  - size: 24
    if: version >= 8

  - size: 20
    if: version == 7


types:
  pid_data:
    seq:
      - id: version
        type: u1
        # valid: 3
        # 3 on newer
        # 1 found on R01.00.00.00

      - id: some_records
        size: 11
        repeat: expr
        repeat-expr: 14

      - id: maybe_controller_type
        type: u1
        valid: 1
        # 1: normal ??

      - id: gain
        type: f4

      - id: sample_time_s
        type: f4

      - id: integral_time_s
        type: f4

      - id: derivative_time_s
        type: f4

      - type: u1

      - id: pv_low
        type: u4

      - id: pv_high
        type: u4

      - id: sp_low
        type: f4

      - id: sp_high
        type: f4

      - id: flag
        type: u4

      - id: alarm_analog_input_module_position
        type: u1

      - size: 8

      - id: range_low
        type: u4

      - id: range_high
        type: u4

      - type: u4
      - id: digital_cycle_time
        type: f4

      - type: u1
      - id: enable_alarm_pv_low
        type: u4
      - id: enable_alarm_pv_high
        type: u4
      - id: enable_alarm_analog_input_error
        type: u4
      - id: alarm_pv_low
        type: f4
      - id: alarm_pv_high
        type: f4
      - type: u1
      - id: pid_init_pou_name
        type: smart_types::strl

      - id: maybe_add_manual_control
        type: u4
      - type: u1
      - type: u4
      - id: enabled
        type: u4
      - type: u4
      - id: memory_allocation_offset
        type: u4

      - id: pid_name
        type: smart_types::strl

      - id: maybe_comment
        type: smart_types::strl
        if: version == 1








































