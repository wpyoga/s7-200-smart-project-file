meta:
  id: pto_config
  endian: le
  imports:
    - smart_types

seq:
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
































































