meta:
  id: hsc_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8d353
  # - size: 0x1bcc95
  # - size: 0x59995
  # - size: 0x59e24
  # - size: 0x3d150
  # - size: 0x9956

  - id: version
    type: u1
    # valid: 4
    # sometimes 2
    # 1 on v1.x

  - type: u4
    valid: 4
    if: version >= 2

  - id: num_hsc
    type: u4

  - id: hsc_data
    type: hsc_data(version)
    repeat: expr
    repeat-expr: num_hsc


types:
  hsc_data:
    params:
      - id: hsc_version
        type: u4
    seq:
      - id: version
        type: u1
        # valid: hsc_version
        # for version < 2, this does not match

      - id: marker
        type: u1
        valid: 1

      - id: mode
        type: u4

      - type: u1
        valid: 1

      - id: hsc_init_pou_name
        type: smart_types::strl

      - type: smart_types::nulls(2)

      - id: marker_2
        type: u4
        valid: 0x01080201

      - id: init_pv
        type: u4

      - type: smart_types::nulls(7)

      - id: marker_2_copy
        type: u4
        valid: 0x01080201

      - id: init_cv
        type: u4

      - type: smart_types::nulls(9)

      - id: reset_input_active_state
        type: u4
        # 0: high
        # 1: low

      - type: smart_types::nulls(8)

      - type: u1
        valid: 1

      - id: interrupt_on_external_reset_activated
        type: u4

      - id: extern_reset_name
        type: smart_types::strl

      - id: interrupt_on_direction_input_changed
        type: u4

      - id: dir_change_name
        type: smart_types::strl

      - id: interrupt_on_pv_eq_cv
        type: u4

      - id: count_eq_name
        type: smart_types::strl

      - id: num_step
        type: u4

      - id: step
        type: step
        repeat: expr
        repeat-expr: num_step


      - id: enabled
        type: u4

      - id: index
        type: u4

      - id: symbol_name
        type: smart_types::strl1


  step:
    seq:
      - id: marker
        type: u1
        valid: 1

      - id: attach_event_to_new_interrupt
        type: u4

      - id: new_interrupt_name
        type: smart_types::strl

      - id: update_pv
        type: u4

      - id: new_pv
        type: u4

      - id: update_cv
        type: u4

      - id: new_cv
        type: u4

      - id: update_counting_direction
        type: u4

      - id: new_counting_direction
        type: u4
        # 0: up
        # 1: down


