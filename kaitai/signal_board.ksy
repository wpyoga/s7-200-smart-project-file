meta:
  id: signal_board
  endian: le
  imports:
    - smart_types


seq:
  # - size: 0x026d

  - id: signal_board_id
    type: u4
    enum: signal_board_id
    
  - id: configured_flag
    type: u4
    enum: configured_notconfigured

  - id: config
    if: configured_flag == configured_notconfigured::configured
    type:
      switch-on: signal_board_id
      cases:
        'signal_board_id::sb_dt04': sb_dt04
        'signal_board_id::sb_ae01': sb_ae01
        'signal_board_id::sb_aq01': sb_aq01
        'signal_board_id::sb_ba01': sb_ba01
        'signal_board_id::sb_cm01_0aa0': sb_cm01_0aa0
        'signal_board_id::sb_cm01_0aa1': sb_cm01_0aa1


types:
  sb_dt04:
    seq:
      - id: block_version
        type: u1

      - type: u4
        valid: 1
      - id: input_offset_start
        type: u2
      - id: input_offset_end
        type: u2
        valid: 0
        # always 0 for SB DT04
      - id: output_offset_start
        type: u2
      - id: output_offset_end
        type: u2
        valid: 0
        # always 0 for SB DT04
      - type: u4
        valid: 0
      - id: slot_number
        type: u4
        enum: slot_number
      - type: u4
        valid: 0
      - type: u4
        valid: 0
      - type: u4
        valid: 0

      - type: u4
        enum: signal_board_id
        valid: _root.signal_board_id
      - type: u4
        valid: 0x02
      - type: u4
        enum: slot_number
        valid: slot_number
      - type: smart_types::null1
      - id: freeze_cfg
        size: 5
      - size: 1
      - id: io_cfg
        type: sb_io_block
      - size: 6
      - size: 18
      - id: trailer1
        size: 8
      - size: 10
      - id: trailer2
        size: 8

  sb_ae01:
    seq:
      - id: block_version
        type: u1

      - type: u4
        valid: 1
      - id: input_offset_start
        type: u2
      - id: input_offset_end
        type: u2
        valid: input_offset_start + 2
      - id: output_offset_start
        type: u2
      - id: output_offset_end
        type: u2
        valid: output_offset_start + 2
      - type: u4
        valid: 0
      - id: slot_number
        type: u4
        enum: slot_number
      - type: u4
        valid: 0
      - type: u4
        valid: 0
      - type: u4
        valid: 0

      - type: u4
        enum: signal_board_id
        valid: _root.signal_board_id
      - type: u4
        valid: 0x02
      - type: u4
        enum: slot_number
        valid: slot_number
      - type: smart_types::null1
      - size: 5
      - size: 2
      - id: analog_input
        type: sb_ai_block
      - size: 18
      - id: trailer1
        size: 8
      - size: 10
      - id: trailer2
        size: 8

  sb_aq01:
    seq:
      - id: block_version
        type: u1

      - type: u4
        valid: 1
      - id: input_offset_start
        type: u2
      - id: input_offset_end
        type: u2
        valid: input_offset_start + 2
      - id: output_offset_start
        type: u2
      - id: output_offset_end
        type: u2
        valid: output_offset_start + 2
      - type: u4
        valid: 0
      - id: slot_number
        type: u4
        enum: slot_number
      - type: u4
        valid: 0
      - type: u4
        valid: 0
      - type: u4
        valid: 0

      - type: u4
        enum: signal_board_id
        valid: _root.signal_board_id
      - type: u4
        valid: 0x02
      - type: u4
        enum: slot_number
        valid: slot_number
      - type: smart_types::null1
      - id: freeze_cfg
        size: 5
      - size: 2
      - id: analog_output
        type: sb_aq_block
      - size: 2
      - id: trailer1
        size: 8
      - size: 10
      - id: trailer2
        size: 8

  sb_ba01:
    seq:
      - id: block_version
        type: u1

      - type: u4
        valid: 1
      - id: input_offset_start
        type: u2
      - id: input_offset_end
        type: u2
        valid: 0
        # always 0 for SB DT04
      - id: output_offset_start
        type: u2
      - id: output_offset_end
        type: u2
        valid: 0
        # always 0 for SB DT04
      - type: u4
        valid: 0
      - id: slot_number
        type: u4
        enum: slot_number
      - type: u4
        valid: 0
      - type: u4
        valid: 1
      - type: u4
        valid: 0

      - type: u4
        enum: signal_board_id
        valid: _root.signal_board_id
      - type: u4
        valid: 0x02
      - type: u4
        enum: slot_number
        valid: slot_number
      - type: smart_types::null1
      - type: u2
        valid: 0x0102
      - id: freeze_output
        type: u4
        enum: freeze_nofreeze
      - type: u2
        valid: 0x0102
      - type: u4
        valid: 0x00
      - type: u1
        valid: 0x07
      - type: u2
        valid: 0x0202
      - type: u4
        valid: 0x01000000
      - type: smart_types::nulls(12)
      - id: battery_low_alarm
        type: u4
        enum: smart_types::enable_disable
      - id: battery_low_flag
        type: u4
        enum: smart_types::enable_disable

  sb_cm01_0aa0:
    seq:
      - id: block_version
        type: u1
      - type: u4
        valid: 1
      - size: 8
      - type: u4
        valid: 0x00
      - id: slot_number
        type: u4
        enum: slot_number
      - type: u4
        valid: 0x01
      - type: u4
        valid: 0x00
      - type: u4
        valid: 0x00
      - type: u4
        enum: signal_board_id
        valid: _root.signal_board_id
      - type: u4
        valid: 0x02
      - type: u4
        enum: slot_number
        valid: slot_number
      - type: smart_types::null1
      - type: u2
        valid: 0x0202
      - id: modbus_station_number
        type: u4
      - id: baud_rate
        type: u4
        enum: baud_rate
      - type: u4
        valid: 0x00
      - id: serial_protocol
        type: u1
        enum: serial_protocol
      - type: u4
        valid: 0x00
      - type: u4  # 0x00 on v2.x, 0x01 on v3
      - type: u4  # 0x00 on v2.x, 0x01 on v3

  sb_cm01_0aa1:
    seq:
      - id: block_version
        type: u1
      - type: u4
        valid: 0x01
      - size: 8
      - type: u4
        valid: 0x00
      - id: slot_number
        type: u4
        enum: slot_number
      - type: u4
        valid: 0x01
      - type: u4
        valid: 0x00
      - type: u4
        valid: 0x00
      - type: u4
        enum: signal_board_id
        valid: _root.signal_board_id
      - type: u4
        valid: 0x02
      - type: u4
        enum: slot_number
        valid: slot_number
      - type: smart_types::null1
      - id: slot_unknown
        if: block_version == 7
        size: 24
      - type: u2
        valid: 0x0202
      - id: modbus_station_number
        type: u4
      - id: baud_rate
        type: u4
        enum: baud_rate
      - type: u4
        valid: 0x00
      - id: serial_protocol
        type: u1
        enum: serial_protocol
      - type: u4
        valid: 0x00
      - type: u4
        valid: 0x01
      - type: u4
        valid: 0x01





  sb_io_block:
    seq:
      - id: input_type
        type: u1
        valid: 2
      - id: input_count
        type: u4
      - id: input_config
        type: u2
        repeat: expr
        repeat-expr: input_count
      - type: u4
        valid: 1
      - type: u1
        valid: 0
      - id: output_type
        type: u1
        valid: 1
      - id: output_count
        type: u4
      - id: output_config
        type: u4
        repeat: expr
        repeat-expr: output_count

  sb_ai_block:
    seq:
      - id: input_type
        type: u1
      - id: input_count
        type: u2
      - size: 2
      - id: ai_data
        repeat: expr
        repeat-expr: input_count
        type: sb_ai_channel

  sb_ai_channel:
    seq:
      - id: type_code
        type: u2
      - size: 1
      - id: rejection_smoothing
        type: u1
      - size: 2
      - id: alarm_flags
        type: u1
      - size: 1

  sb_aq_block:
    seq:
      - id: output_type
        type: u1
      - id: output_count
        type: u1
      - size: 2
      - id: aq_data
        repeat: expr
        repeat-expr: output_count
        type: sb_aq_channel

  sb_aq_channel:
    seq:
      - id: type_code
        type: u2
      - size: 1
      - id: alarm_flags
        type: u1
      - id: output_cfg
        type: u1
      - id: substitute_value
        type: u2
      - size: 2






enums:

  configured_notconfigured:
    0x01: configured
    0x00: not_configured

  slot_number:
    0x01: slot_1
    0x00: slot_0

  freeze_nofreeze:
    0x01: freeze
    0x00: no_freeze

  baud_rate:
    1: bps_9600
    2: bps_19200
    4: bps_187500

  serial_protocol:
    0: rs485
    1: rs232

  signal_board_id:
    0x80002000: sb_dt04
    0x80002011: sb_ae01
    0x80002010: sb_aq01
    0x8000201d: sb_ba01
    0x8000201e: sb_cm01_0aa0
    0x8000201f: sb_cm01_0aa1



