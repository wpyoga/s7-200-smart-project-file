meta:
  id: pwm_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8d62c
  # - size: 0x1bcf89
  # - size: 0x5a1a6

  - type: u1
    valid: 1

  - id: num_pwm
    type: u4

  - id: pwm_data
    type: pwm_data
    repeat: expr
    repeat-expr: num_pwm


types:
  pwm_data:
    seq:
      - id: marker
        type: u1
        valid: 1

      - id: enabled
        type: u4

      - id: index
        type: u4

      - id: pwm_name
        type: smart_types::strl

      - id: time_base
        type: u4
        # 0: microseconds
        # 1: milliseconds

      - id: some_record_2
        type: some_record_2
        repeat: expr
        repeat-expr: 4

  some_record_2:
    seq:
      - type: u1
        valid: 2

      - type: u1
        valid: 3

      - type: u1
        valid: 0x40

      - type: smart_types::nulls(8)










































