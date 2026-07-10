meta:
  id: motion_axis_group_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x62789

  - id: marker
    type: u1

  - id: num_axis_group
    type: u1

  - type: smart_types::nulls(3)
    # TODO: maybe figure out if this belongs to axis_group

  - id: axis_group
    type: axis_group
    repeat: expr
    repeat-expr: num_axis_group


types:
  axis_group:
    seq:
      - type: smart_types::null1

      - id: maybe_index
        type: u4

      - id: maybe_enabled
        type: u4

      - type: u4
      - type: u4
      - type: u1

      - id: unit
        type: smart_types::strl

      - type: u4

      - type: f8

      - id: name
        type: smart_types::strl

      - id: memory_allocation_offset
        type: u4

      - type: u4

      - id: num_path
        type: u4

      - id: path
        type: path
        repeat: expr
        repeat-expr: num_path

      - type: smart_types::null1

      - id: maybe_index_copy
        type: u4
        valid: maybe_index

      - type: smart_types::rec(1,4)

      - size: 200
        # TODO: maybe the last 2 bytes denote the total # of segments


  path:
    seq:
      - type: u1

      - id: name
        type: smart_types::strl

      - id: comment
        type: smart_types::strl

      - type: u4

      - id: num_segment
        type: u2

      - id: segment
        type: segment
        repeat: expr
        repeat-expr: num_segment

      - size: 116


  segment:
    seq:
      - id: execution
        type: u1

      - id: target_speed
        type: f8

      - id: end_x_pos_cm
        type: f8

      - id: end_y_pos_cm
        type: f8

      - id: unknown
        type: f8
        valid: 0.0

      - id: accel_ms
        type: u4

      - id: decel_ms
        type: u4

      - id: jerk_ms
        type: u4

      - id: target_speed_str
        type: smart_types::strl

      - id: end_x_pos_cm_str
        type: smart_types::strl

      - id: end_y_pos_cm_str
        type: smart_types::strl

      - id: unknown_str
        type: smart_types::strl

      - id: accel_ms_str
        type: smart_types::strl

      - id: decel_ms_str
        type: smart_types::strl

      - id: jerk_ms_str
        type: smart_types::strl

      - id: flags
        size: 131


































