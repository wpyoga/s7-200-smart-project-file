meta:
  id: system_block_mwp
  endian: le
  bit-endian: be
  imports:
    - smart_types

seq:
  # - size: 0x0577
  # - size: 0x058e
  # - size: 0x0593
  # - size: 0x057e
  # - size: 0x056d
  # - size: 0x0588
  # - size: 0x579
  # - size: 0x57d
  # - size: 0x56b
  # - size: 0x53d

  # maybe this needs to be split into 2
  # the first byte looks like the main version number
  # the second byte (sub-version?) seems to determine structure
  # also, first byte seems to have its own series: 0e, 0f, 13
  # the second byte also seems to have its own series: 01, 03, 06
  # - 13 06: R03.01.00.00
  # - 0F 06: R02.04.00.00
  # - 0F 03: R01.00.00.00
  # - 0E 01: R04.00 / 4.0.0.46 / MicroWin / pre-SMART
  - id: version
    type: u2
    valid:
      any-of: [0x010e]

  - type:
      switch-on: version
      cases:
        0x010e: cpu_security_mwp

  - type: u1

  - type: u1

  - id: output_tables_digital
    type: output_tables_digital

  - type: u1
    valid: 1

  - id: retentive_range
    type: retentive_range
    repeat: expr
    repeat-expr: 6

  - id: cpu_comm_port
    type: cpu_comm_port

  - id: input_filter_digital
    type: input_filter_digital

  - id: input_filter_analog
    type: input_filter_analog

  - id: pulse_catch_bits
    type: pulse_catch_bits

  - id: unknown
    type: u1
    valid: 1

  - id: em_config
    type: em_config
    repeat: expr
    repeat-expr: 7

  - type: u1
    valid: 1

  - id: comms_background_percent
    type: u4

  - type: u1
    valid: 1

  - id: output_tables_analog
    type: output_tables_analog

  - type: u1
    valid: 1

  - id: led_on_item_forced
    type: u4

  - id: led_on_module_io_error
    type: u4

  - type: u1
    valid: 1

  - id: disable_edit_in_run
    type: u4


types:
  retentive_range:
    seq:
      - type: u4
        valid: 0
      - id: data_width
        type: u4
        enum: data_width
      - id: memory_area
        type: u4
        enum: memory_area
      - id: offset
        type: u4
      - id: count
        type: u4

  cpu_comm_port:
    seq:
      - type: u1
        valid: 1

      - id: port_0_plc_address
        type: u4

      - id: port_0_highest_address
        type: u4

      - id: port_0_baud_rate
        type: u4
        # 0: 9.6kbps
        # 2: 19.2kbps ??? TODO: verify
        # 4: 187.5kbps

      - id: port_0_retry_count
        type: u4

      - id: port_0_gap_update_factor
        type: u4

      - id: port_1_plc_address
        type: u4

      - id: port_1_highest_address
        type: u4

      - id: port_1_baud_rate
        type: u4
        # 0: 9.6kbps
        # 2: 19.2kbps ??? TODO: verify
        # 4: 187.5kbps

      - id: port_1_retry_count
        type: u4

      - id: port_1_gap_update_factor
        type: u4

  input_filter_digital:
    seq:
      - type: u1
        valid: 1

      # input filter is divided into groups:
      # group 0: I0.0 ~ I0.3
      # group 1: I0.4 ~ I0.7
      # group 1: I1.0 ~ I1.3 ??? TODO: verify
      # group 2: I1.4 ~ I1.7 ??? TODO: verify
      # group 3: I2.0 ~ I2.3 ??? TODO: verify
      # group 4: I2.4 ~ I2.7 ??? TODO: verify
      - id: filter
        type: u4
        repeat: expr
        repeat-expr: 6
        # 7: 12.80 ms ??? TODO: verify
        # 6:  6.40 ms
        # 5:  3.20 ms
        # 3:  1.60 ms
        # 2:  0.80 ms ??? TODO: verify
        # 1:  0.40 ms ??? TODO: verify
        # 0:  0.20 ms ??? TODO: verify

  input_filter_analog:
    instances:
      deadband:
        value: deadband_16 * 16
    seq:
      - type: u1
        valid: 2

      # 32 values for input filters from AIW0 to AIW62
      - type: u4
        repeat: expr
        repeat-expr: 32

      - id: num_samples
        type: u4

      - id: deadband_16
        type: u4

  pulse_catch_bits:
    seq:
      - type: u1
        valid: 1

      # 24 bits from I0.0 to I2.7
      - type: u4
        repeat: expr
        repeat-expr: 24
        valid:
          any-of: [1, 0]

  em_config:
    seq:
      - type: u4
        valid: 0

      - type: u4
        valid: 2

      - id: em_type
        type: u4
        # 01: not_present
        # 10: present

      - id: configuration_address
        type: u4

  cpu_security_mwp:
    seq:
      - id: password_encoded
        size: 8

      - id: privilege_level
        type: u2
        # 1: Level 1 = Full
        # 2: Level 2 = Partial
        # 3: Level 3 = Minimum
        # 4: Level 4 = Disallow Upload

      - type: u2

  # 128 outputs from Q0.0 to Q15.7
  output_tables_digital:
    seq:
      - id: freeze
        type: u4

      - id: on_in_stop
        type: u4
        repeat: expr
        repeat-expr: 128

  # 32 outputs from AQW0 to AQW62
  output_tables_analog:
    seq:
      - id: freeze
        type: u4
      - id: on_in_stop
        type: s4
        repeat: expr
        repeat-expr: 32









enums:
  data_width:
    0x2: b
    0x4: w
    0x8: d

  memory_area:
    0x10: v
    0x20: m
    0x40: t
    0x80: c



