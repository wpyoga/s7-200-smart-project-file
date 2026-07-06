meta:
  id: unknown_data
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8bf2c

  - type: smart_types::nulls(2)

  - id: some_name
    type: smart_types::strl

  - type: smart_types::nulls(2)

  - type: u1
    valid: 1

  - type: smart_types::nulls(4)

  - id: maybe_hash
    size: 16

  # unknown block 1

  - type: u1
    valid: 1

  - type: smart_types::nulls(4)

  - id: version
    type: u1
    # 3: v2.x
    # 1: v1.x

  - size: 8
    if: version == 3

  - id: num_records
    type: u4

  - id: unknown_records_v2
    type: unknown_records_v2
    size: 715
    if: version == 3
    repeat: expr
    repeat-expr: num_records

  - id: unknown_records_v1
    type: unknown_records_v1
    size: 562
    if: version == 1
    repeat: expr
    repeat-expr: num_records

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

  # unknown block 3 (HSC)

  - type: u1
    valid: 4

  - type: u4
    valid: 4

  - id: num_hsc
    type: u4

  - id: hsc_data
    size: 120
    repeat: expr
    repeat-expr: num_hsc

  # unknown block 4

  - type: u1
    valid: 1

  - id: num_records_2
    type: u4

  - id: unknown_records_2
    size: 59
    repeat: expr
    repeat-expr: num_records_2

  # unknown block 5

  - type: u1
    valid: 2

  - id: num_records_3
    type: u4

  - id: unknown_records_3
    size: 442
    repeat: expr
    repeat-expr: num_records_3

  # unknown block 6

  - type: smart_types::nulls(4)

  - type: u1
    valid: 4

  - id: num_records_4
    type: u4

  - type: smart_types::nulls(4)

  - id: net_exe_pou_name
    type: smart_types::strl

  - size: 22

  # unknown block 7

  - type: u1
    valid: 1

  - type: u4
    valid: 0x83

  - id: num_records_5
    type: u4

  - id: unknown_records_5
    size: 36
    repeat: expr
    repeat-expr: num_records_5

  # profinet block

  - id: profinet_data
    size: 78202

  # hsc block #2

  - type: u1
    valid: 4

  - type: u4
    valid: 4

  - id: num_hsc_2
    type: u4

  - id: hsc_data_2
    size: 128
    repeat: expr
    repeat-expr: num_hsc_2

  - type: smart_types::nulls(16)


types:
  unknown_records_v2:
    seq:
      - type: u2
        valid: 0x0104

      - type: smart_types::nulls(8)

      - id: version
        type: u1
        # 2: v2.x
        # 1: v1.x

      - type: smart_types::nulls(4)

      - type: u2
        valid: 2

      - type: u2
        valid: 0x6d63

      - id: marker
        type: u2
        valid: 0x1388

      - type:
          switch-on: version
          cases:
            2: smart_types::nulls(8)
            1: smart_types::nulls(4)


  unknown_records_v1:
    seq:
      - type: u1


  pid_data:
    seq:
      - type: u1



















































