meta:
  id: pid_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8ca8b

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

      - type: u1
        valid: 1

      - type: smart_types::nulls(2)

      - id: some_attr
        type: u1
        # f0: v2.x
        # 80: v1.x
        # same values as in unknown_data20

      - id: some_attr_2
        type: u1
        valid: 0x3f
        # same value as in unknown_data20

      - type: smart_types::nulls(2)

      - id: some_attr_copy
        type: u1
        valid: some_attr

      - id: some_attr_2_copy
        type: u1
        valid: some_attr_2

      - type: smart_types::nulls(2)

      - type: u2
        valid: 0x4120

      - type: smart_types::nulls(4)

      - type: u2
        valid: 1

      - type: smart_types::nulls(4)

      - size: 23

      - size: 17

      - size: 17

      - type: u4

      - type: u1
        valid: 2

      - id: pid_name
        type: smart_types::strl

      - type: smart_types::nulls(4)

      - type: u1
        valid: 1

      - id: some_index_array
        size: 16

      - type: smart_types::nulls(2)











































