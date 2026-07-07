meta:
  id: hsc_config_2
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0xa1203

  - type: u1
    valid: 4

  - type: u4
    valid: 4

  - id: num_hsc_2
    type: u4

  - id: hsc_data_2
    type: hsc_data_2
    size: 128
    repeat: expr
    repeat-expr: num_hsc_2

types:
  hsc_data_2:
    seq:
      - id: marker
        type: u2
        valid: 0x0104

      - type: smart_types::nulls(4)

      - type: u1
        valid: 1

      - id: hsc_init_pou_name
        type: smart_types::strl

      - type: smart_types::nulls(2)

      - id: marker_2
        type: u4
        valid: 0x01080201

      - type: u1
        # valid: 0
        # 00 or 0a

      - type: smart_types::nulls(10)

      - id: marker_2_copy
        type: u4
        valid: 0x01080201

      - type: u1
        valid: 0

      - type: smart_types::nulls(24)

      - type: u1
        valid: 1

      - type: smart_types::nulls(4)

      - id: extern_reset_name
        type: smart_types::strl

      - type: smart_types::nulls(4)

      - id: dir_change_name
        type: smart_types::strl

      - type: smart_types::nulls(4)

      - id: count_eq_name
        type: smart_types::strl

      - type: smart_types::nulls(8)

      - id: index
        type: u1

      - type: smart_types::nulls(4)

      - type: u4
        valid: 0

      - type: u2
        valid: 0xffff

      - type: u2
        valid: 0xffff























































