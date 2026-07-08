meta:
  id: pid_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8ca8b
  # - size: 0x43380

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

  - size: 42


types:
  pid_data:
    seq:
      - type: u1
        valid: 3

      - id: some_records
        size: 11
        repeat: expr
        repeat-expr: 14
        # this is the same format found in unknown_data20
        # might be related

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

      - type: smart_types::nulls(4)

      - size: 9

      - id: range_low
        type: u4

      - id: range_high
        type: u4

      - type: f4

      - type: f4
      - type: u1
      - type: u4
      - type: u4
      - type: u4
      - id: alarm_pv_low
        type: f4
      - id: alarm_pv_high
        type: f4
      - type: u1
      - id: pid_init_pou_name
        type: smart_types::strl

      - type: u4
      - type: u4
      - type: u1
      - type: u4
      - type: u4
      - id: memory_allocation_offset
        type: u4

      - id: pid_name
        type: smart_types::strl











































