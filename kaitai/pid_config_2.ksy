meta:
  id: pid_config_2
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x62f89

  - id: marker
    type: u1
    valid: 0x1b

  - type: u2
    valid: 2

  - size: 96

  - id: marker_2
    type: u2
    valid: 0x1b

  - type: u1
    valid: 2

  - id: num_pid
    type: u4

  - id: pid
    type: pid
    repeat: expr
    repeat-expr: num_pid
    size: 347

  - type: smart_types::nulls(100)


types:
  pid:
    seq:
      - id: marker
        type: u1

      - type: u1
        valid: 2

      - type: smart_types::nulls(8)

      - id: bidi_gain
        type: f4
      - id: bidi_integral
        type: f4
      - id: bidi_derivative
        type: f4

      - id: enable_control_range
        type: u4
      - id: enable_reverse_control_range
        type: u4
      - id: control_range
        type: f4
      - id: reverse_control_range
        type: f4

      - type: smart_types::nulls(84)

      - id: enable_dead_zone
        type: u4
      - id: dead_zone
        type: f4

      - id: enable_reverse_dead_zone
        type: u4
      - id: reverse_dead_zone
        type: f4

      - type: u1

      - type: smart_types::nulls(8)

      - type: u4

      - type: u4
        valid: 0

      - id: digital_cycle_time
        type: f4

      - size: 11
        repeat: expr
        repeat-expr: 8

      - type: smart_types::nulls(100)








































































