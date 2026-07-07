meta:
  id: pid_config
  endian: le
  imports:
    - smart_types

seq:
  # unknown block 2 (PID)

  - type: u1
    valid: 1

  - id: num_pid
    type: u4

  - id: pid_data
    type: pid_data
    size: 274
    repeat: expr
    repeat-expr: num_pid

  - id: pid_int_pou_name
    type: smart_types::strl

  - size: 42


types:
  pid_data:
    seq:
      - type: u1



















































