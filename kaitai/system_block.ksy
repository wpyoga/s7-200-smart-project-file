meta:
  id: system_block
  endian: le
  imports:
    - smart_types
    - signal_board
  
seq:

  - id: version
    size: 2

  - type:
      switch-on: version
      cases:
        '[0x13,0x06]': smart_types::nulls(44)
        '[0x0f,0x06]': smart_types::nulls(44)
        '[0x0f,0x03]': smart_types::nulls(35)

  - type: smart_types::u2_val(0x0100)

  - type: smart_types::u1_val(0x02)

  - id: modbus_station_port0
    type: u4

  - id: baud_rate
    type: u4
    enum: baud_rate

  - type: smart_types::nulls(8)

  - type: smart_types::u1_val(0x01)

  - id: retentive_ranges
    repeat: expr
    repeat-expr: 6
    type: retentive_range

  - id: sys_version
    type: u1

  - id: cpu_privileges
    type: u4

  # TODO: verify
  - id: serial_port_security
    type: u4
    enum: allow_disallow_reversed

  - id: password_block
    type:
      switch-on: version
      cases:
        '[0x13,0x06]': password_sha256
        '[0x0f,0x06]': password_sha1
        '[0x0f,0x03]': password_v1

  - type: smart_types::u1_val(0x01)

  - id: comms_background_percent
    type: u4

  - type: smart_types::u1_val(0x01)

  - type: u1

  - id: startup_mode
    type: u1
    enum: startup_mode

  - type: smart_types::nulls(2)

  - id: allow_missing_hw
    type: u4
    enum: allow_disallow

  - id: allow_hw_errors
    type: u4
    enum: allow_disallow

  - type: smart_types::u1_val(0x03)

  - id: ip_config
    type: ip_config

  - type: smart_types::nulls(16)

  - id: legacy_extra
    if: version == [0x0f,0x03]
    type: legacy_extra

  - id: cpu_config
    if: version != [0x0f,0x03]
    type: cpu_config

  - id: cpu_di_config
    if: version != [0x0f,0x03]
    type: cpu_di_config

  - id: cpu_do_config
    if: version != [0x0f,0x03]
    type: cpu_do_config

  - id: signal_board_info
    type:
      switch-on: sys_version
      cases:
        6: signal_boards
        5: signal_board_1

  # - id: expansion_modules
  #   type: expansion_module_block

  # - id: trailing_records
  #   type: trailing_records

  # - id: extra_settings
  #   if: file_version == "R03.01.00.00"
  #   type: extra_settings


types:

  retentive_range:
    seq:
      - size: 4
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
        type: u4
      - id: netmask
        type: u4
      - id: gateway
        type: u4
      - id: station_name
        size: 64

  cpu_config:
    seq:
      - type: u1
        valid: 0x00

      - id: communication_restrict
        type: communication_restrict
        if: _root.version != [0x0f,0x03]

      - id: cpu_type
        type: cpu_type

      - type: smart_types::u2_val(0x8000)

      - id: cpu_block_version
        type: u1

      - type: smart_types::u2_val(0x0001)

      - type: smart_types::nulls(30)

      - id: cpu_type2
        type: cpu_type
        # validate by ourselves

      - type: smart_types::u2_val(0x8000)

      - type: u4
        valid: 0x01

      - type: u4
        valid: 0x00

      - id: plc_version
        if: _root.version != [0x0f,0x03]
        type: smart_types::strl1

      - if: cpu_block_version == 7
        size: 24

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
      - id: type
        type: u1
      - id: count
        type: u2
      - size: 2
      - id: entries
        repeat: expr
        repeat-expr: count
        type: cpu_di_entry

  cpu_di_entry:
    seq:
      - size: 1
      - id: filter_flags
        type: u1

  cpu_do_config:
    seq:
      - id: type
        type: u1
      - id: freeze
        type: u1
      - size: 3
      - id: sub_type
        type: u1
      - id: count
        type: u2
      - id: records
        repeat: expr
        repeat-expr: count
        size: 4
      - size: 2

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

  cpu_io:
    seq:
      - type: u1
        enum: cpu_io

  cpu_io_g2:
    seq:
      - type: u1
        enum: cpu_io_g2


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

  cpu_io:
    0x02: xx20
    0x03: xx30
    0x04: xx40
    0x06: xx60
    
  cpu_io_g2:
    0x03: xx32






