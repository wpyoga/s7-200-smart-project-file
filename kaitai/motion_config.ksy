meta:
  id: motion_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8bf4d
  # - size: 0x3939c
  # - size: 0x41ca5
  # - size: 0x426af

  - type: u1
    valid: 1

  - type: smart_types::nulls(4)

  - id: version
    type: u1
    # 3: v2.x
    # 1: v1.x

  - size: 8
    if: version == 3

  - id: num_axis
    type: u4

  - id: axis_v2
    type: axis_v2
    # size: 715
    if: version == 3
    repeat: expr
    repeat-expr: num_axis

  - id: axis_v1
    type: axis_v1
    size: 562
    if: version == 1
    repeat: expr
    repeat-expr: num_axis


types:
  axis_v2:
    seq:
      - id: marker
        type: u2
        valid: 0x0104

      - type: smart_types::nulls(8)

      - id: version
        type: u1
        # 2: v2.x with double precision floats
        # 1: v1.x with single precision floats

      - id: maybe_measurement_system
        type: u4
        # 0: engineering units
        # 1: relative pulses

      - id: base_unit
        type: smart_types::strl
        # if: maybe_measurement_system == 1

      - id: pulses_per_motor_revolution
        type: u4

      - id: cm_per_motor_revolution
        type: f8

      - id: input_config_lmt_pos
        type: input_config
        if: version == 2

      - id: input_config_lmt_neg
        type: input_config
        if: version == 2

      - id: input_config_lmt_stp
        type: input_config
        if: version == 2

      - id: input_config_rps
        type: input_config
        if: version == 2

      - id: input_config_zp
        type: input_config
        if: version == 2

      - id: input_config_trig
        type: input_config
        if: version == 2

      - id: some_records_v1
        size: 21
        repeat: expr
        repeat-expr: 6
        if: version == 1

      - id: output_config
        type: output_config

      - type: u1

      - type: u1
        valid: 2

      # values with cm/s units are always stored as cm/s
      # if the axis works on pulses, values are converted to cm/s first
      - id: motor_speed_max_cm_s
        type: f8

      - id: motor_speed_min_cm_s
        type: f8

      - id: motor_speed_start_stop_cm_s
        type: f8

      - type: u1

      - id: jog_speed_cm_s
        type: f8

      - id: jog_increment_cm
        type: f8

      - type: u1

      - id: motor_accel_ms
        type: u4

      - id: motor_decel_ms
        type: u4

      - type: u1

      - id: jerk_time_ms
        type: u4

      - type: u1

      - id: backlash_compensation_cm
        type: f8

      - size: 14

      - type: f8

      - type: u4

      - type: u4

      - type: u4

      - type: u2

      - type: smart_types::unknown(12)

      - id: num_profile
        type: u4

      - id: profile
        type: profile
        repeat: expr
        repeat-expr: num_profile

      - type: u1

      - id: some_flags
        type: u4
        repeat: expr
        repeat-expr: 19

      - id: memory_allocation_offset
        type: u4

      - id: axis_name
        type: smart_types::strl

      - type: smart_types::unknown(8)




      - id: some_records_2
        size: 11
        repeat: expr
        repeat-expr: 28


  input_config:
    seq:
      - id: marker
        type: u1
        valid: 2
      - id: enabled
        type: u4
      - type: u4
      - id: input_bit
        type: u4
      - type: u4
      - id: input_hsc
        type: u4
      - type: u4

  output_config:
    seq:
      - id: marker
        type: u1
        valid: 1
      - id: enabled
        type: u4
      - id: output_bit
        type: u4
      - type: u4
      - type: u4



  profile:
    seq:
      - id: marker
        type: u1
        valid: 2

      - id: num_profile_step
        type: u4

      - id: profile_step
        type: profile_step
        repeat: expr
        repeat-expr: num_profile_step

      - id: name
        type: smart_types::strl
        if: num_profile_step > 0

      - id: comment
        type: smart_types::strl
        if: num_profile_step > 0

      - type: u4
        repeat: expr
        repeat-expr: 4
        if: num_profile_step > 0


  profile_step:
    seq:
      - id: marker
        type: u1
        valid: 02

      - id: target_speed
        type: f8

      - id: ending_position
        type: f8

      - type: f8
        valid: 0.0


  axis_v1:
    seq:
      - type: u1











































