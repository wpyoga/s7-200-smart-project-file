meta:
  id: system_block
  endian: le
  bit-endian: be
  imports:
    - smart_types
    - signal_board
    - expansion_module
  
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
      any-of: [0x030f, 0x060f, 0x0613]

  - type:
      switch-on: version
      cases:
        0x0613: smart_types::nulls(44)
        0x060f: smart_types::nulls(44)
        0x030f: smart_types::nulls(35)

  - id: sometimes_version_info
    type: smart_types::strl1
    # string is usually 0-length (empty)
    # V3 template shows V01.00.00_00.00.00.00, might be minor version?
    # after saved by version 3.01, this string is empty

  - type: u1
    valid: 1

  - id: cpu_rs485
    type: cpu_rs485

  - type: u1
    valid: 1

  - id: retentive_range
    type: retentive_range
    repeat: expr
    repeat-expr: 6

  - id: cpu_security
    type: cpu_security(version)

  - type: u1
    valid: 1

  - id: comms_background_percent
    type: u4

  - type: u1
    valid: 1

  - type: u1

  - id: startup_mode
    type: u1
    enum: startup_mode

  - type: u2
    valid: 0

  - id: allow_missing_hw
    type: u4
    enum: allow_disallow

  - id: allow_hw_errors
    type: u4
    enum: allow_disallow

  - type: u1
    valid: 3

  - id: ip_config
    type: ip_config

  - type: smart_types::nulls(16)

  - id: legacy_extra
    if: cpu_security.block_version == 3
    type: legacy_extra

  - id: cpu_config
    if: cpu_security.block_version != 3
    type: cpu_config

  - id: cpu_di_config
    if: cpu_security.block_version != 3
    type: cpu_di_config

  - id: cpu_do_config
    if: cpu_security.block_version != 3
    type: cpu_do_config

  - id: signal_board_info
    type:
      switch-on: cpu_security.block_version
      cases:
        6: signal_boards
        5: signal_board_1
        3: signal_board_1

  - id: expansion_module_info
    type: expansion_modules

  - id: num_axis
    type: u4

  - id: motion_wizard_data
    type: motion_wizard_data
    repeat: expr
    repeat-expr: num_axis

  - id: unknown_data_2
    type: smart_types::rec(2,4)
    if: cpu_security.block_version == 6

  - id: unknown_data_3
    type: smart_types::rec(4,4)
    if: cpu_security.block_version == 6


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

  cpu_security:
    params:
      - id: version
        type: u2
    seq:
      - id: block_version
        type: u1
        valid:
          any-of: [6, 5, 3]
        # 6 -- R03
        # 5 -- R02
        # 3 -- R01

      - id: cpu_privileges
        type: u4

      # TODO: verify
      - id: serial_port_security
        type: u4
        enum: allow_disallow

      - id: plc_password
        type:
          switch-on: version
          cases:
            0x0613: password_sha256
            0x060f: password_sha1
            0x030f: password_v1

  password_sha256:
    seq:
      - id: salt
        size: 2
      - id: hash
        size: 32

  password_sha1:
    seq:
      - id: salt
        size: 2
      - id: hash
        size: 20

  password_v1:
    seq:
      - size: 4

  ip_config:
    seq:
      - id: fixed_ip
        type: u4
      - id: ip_addr
        type: smart_types::ipv4_addr
      - id: netmask
        type: smart_types::ipv4_addr
      - id: gateway
        type: smart_types::ipv4_addr
      - id: station_name
        type: smart_types::strn(64)


  cpu_rs485:
    seq:
      - type: u1
        valid: 2

      - id: modbus_station_port0
        type: u4

      - id: baud_rate
        type: u4
        enum: baud_rate

      - type: smart_types::nulls(8)


  cpu_config:
    seq:
      - type: u1
        valid: 0x00

      - id: communication_restrict
        type: communication_restrict
        if: _parent.version != 0x030f

      - id: cpu_type
        type: cpu_type

      - type: u2
        valid: 0x8000

      - id: block_version
        type: u1

      - type: u2
        valid: 1

      - type: smart_types::nulls(10)
      - type: u4
      - type: smart_types::nulls(16)

      - id: cpu_type2
        type: cpu_type
        # validate by ourselves

      - type: u2
        valid: 0x8000

      - type: u4
        valid: 0x01

      - type: u4
        valid: 0x00

      - id: plc_version
        if: _root.version != 0x030f
        type: smart_types::strl1

      - size: 24
        if: block_version == 7

      - type: u2
        valid: 0x0101
      
      - type: u4
        valid: 0x00

  communication_restrict:
    seq:
      - id: restrict_writes
        type: u4
        enum: restrict_norestrict
      - id: vmem_offset
        type: u4
      - id: vmem_count
        type: u4

  cpu_type:
    seq:
      - id: cpu_series
        type: u1
        enum: cpu_series
      - id: cpu_io
        type: 
          switch-on: cpu_series
          cases:
            'cpu_series::st': cpu_io
            'cpu_series::sr': cpu_io
            'cpu_series::st_g2': cpu_io_g2
            'cpu_series::cr_s': cpu_io
            'cpu_series::cr': cpu_io

  cpu_io:
    seq:
      - type: u1
        enum: cpu_io

  cpu_io_g2:
    seq:
      - type: u1
        enum: cpu_io_g2

  legacy_extra:
    seq:
      - type: smart_types::null1
      - type: smart_types::nulls(8)
      - type: smart_types::u4_val(0x64)
      - type: smart_types::u4_val(0x00)
      - type: smart_types::u4_val(0x03)
      - type: smart_types::nulls(32)
      - type: smart_types::u2_val(0x0100)

  cpu_di_config:
    seq:
      - id: version
        type: u1
      - id: count
        type: u4
      - id: entries
        repeat: expr
        repeat-expr: count
        type: cpu_di_entry

  cpu_di_entry:
    seq:
      - id: reserved
        type: b8
      - id: unit
        type: b1
        enum: ms_or_us
      - id: pulse_catch
        type: b1
      - id: input_filter
        type: b6
        enum: input_filter

  cpu_do_config:
    seq:
      - id: version
        type: u1
      - id: freeze
        type: u4
      - id: sub_type
        type: u1
      - id: count
        type: u4
      - id: output_in_stop
        type: u4
        repeat: expr
        # round up to multiples of 8
        repeat-expr: ((count + 7) / 8) * 8

  trailing_records:
    seq:
      - id: count
        type: u2
      - id: records
        repeat: expr
        repeat-expr: count
        size: 8
      - size: 2

  extra_settings:
    seq:
      - id: flags
        type: u1
      - size: 4
      - id: put_get
        type: u1
      - size: 3
      - id: unknown1
        type: u1
      - size: 3
      - id: unknown2
        type: u1
      - id: variable_records
        repeat: until
        repeat-until: _io.eof
        type: var_record

  var_record:
    seq:
      - id: len
        type: u2
      - id: data
        size: len * 4
      - size: 2

  signal_board_1:
    seq:
      - id: signal_board
        type: signal_board

  signal_boards:
    seq:
      - id: num_signal_boards
        type: u4
      - id: signal_boards
        type: signal_board
        repeat: expr
        repeat-expr: num_signal_boards

  expansion_modules:
    seq:
      - id: num_expansion_modules
        type: u4
      - id: expansion_modules
        type: expansion_module
        repeat: expr
        repeat-expr: num_expansion_modules

  motion_wizard_data:
    seq:
      - type: smart_types::nulls(4)

      - id: configured
        type: u4

      - id: motion_axis_config
        type: motion_axis_config
        size: 85
        if: configured == 1

  motion_axis_config:
    seq:
      - id: marker
        type: u2
        valid: 0x0106

      - type: smart_types::nulls(15)

      - id: index
        type: u2

      - type: smart_types::nulls(27)

      - id: marker_2
        type: u1
        valid: 2

      - size: 9

      - id: flag
        type: u1

      - id: output_bit
        type: u4
        # bit starts from Q0.0 = 0 and counting up

      - type: smart_types::nulls(12)

      - type: u4
        valid: 2

      - type: u4
        valid: 16

      - id: mem_alloc_offset
        type: u4





enums:

  baud_rate:
    1: bps_9600
    2: bps_19200
    4: bps_187500

  data_width:
    0x2: b
    0x4: w
    0x8: d

  memory_area:
    0x10: v
    0x20: m
    0x40: t
    0x80: c

  allow_disallow:
    0x01: allow
    0x00: disallow

  allow_disallow_reversed:
    0x01: disallow
    0x00: allow

  startup_mode:
    0x02: last
    0x01: run
    0x00: stop

  restrict_norestrict:
    0x01: restrict
    0x00: no_restrict

  cpu_series:
    0x00: st
    0x01: sr
    0x20: st_g2
    0x81: cr_s
    0x80: cr

  cpu_io:
    0x02: xx20
    0x03: xx30
    0x04: xx40
    0x06: xx60
    
  cpu_io_g2:
    0x03: xx32

  ms_or_us:
    0: ms
    1: us

  input_filter:
    14: none
    9: filter_12_8
    7: filter_6_4
    6: filter_3_2
    5: filter_1_6
    4: filter_0_8
    3: filter_0_4
    2: filter_0_2












