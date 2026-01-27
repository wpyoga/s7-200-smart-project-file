meta:
  id: expansion_module
  endian: le
  imports:
    - smart_types


seq:
  - id: module_id
    type: u4
    enum: expansion_module_id

  - id: configured_flag
    type: u4
    enum: configured_notconfigured

  - id: config
    type: expansion_module_config
    if: configured_flag == configured_notconfigured::configured


types:

  expansion_module_config:
    seq:
      - id: block_version
        type: u1

      - type: u4
        valid: 0x01
        
      - type: u4
      - type: u4
      
      - type: u4
        valid: 0x00
        
      - id: module_number
        type: u4
        enum: module_number

      - type: u4
        valid: 0x00
      - type: u4
        valid: 0x00
      
      - id: some_flag
        type: u4

      - id: module_id
        type: u4
        enum: expansion_module_id
        valid: _root.module_id

      - type: u4
        valid: 0x03

      # validate by ourselves
      - id: module_number2
        type: u4
        enum: module_number

      - type: u2
        valid: 0x0300

      - type: u4
        valid: 0x01

      - type: smart_types::null1

      - id: em_io_rec_type
        type: u1

      - id: em_aio_rec_type
        type: u1
        if: em_io_rec_type == 0x00

      - id: module_specific
        type:
          switch-on: _root.module_id
          cases:
            expansion_module_id::em_de08: em_de08_config(em_io_rec_type)
            expansion_module_id::em_dt08: em_dt08_config(em_io_rec_type)
            expansion_module_id::em_dr08: em_dr08_config(em_io_rec_type)
            expansion_module_id::em_dt16: em_dt16_config(em_io_rec_type)
            expansion_module_id::em_dr16: em_dr16_config(em_io_rec_type)
            expansion_module_id::em_dt32: em_dt32_config(em_io_rec_type)
            expansion_module_id::em_dr32: em_dr32_config(em_io_rec_type)
            expansion_module_id::em_ae04: em_ae04_config(em_aio_rec_type)
            expansion_module_id::em_aq02: em_aq02_config(em_aio_rec_type)
            expansion_module_id::em_am06: em_am06_config(em_aio_rec_type)
            expansion_module_id::em_ar02: em_ar02_config(em_aio_rec_type)
            expansion_module_id::em_at04: em_at04_config(em_aio_rec_type)
            expansion_module_id::em_am03: em_am03_config(em_aio_rec_type)
            expansion_module_id::em_ae08: em_ae08_config(em_aio_rec_type)
            expansion_module_id::em_ar04: em_ar04_config(em_aio_rec_type)
            expansion_module_id::em_aq04: em_aq04_config(em_aio_rec_type)
            expansion_module_id::em_de16: em_de16_config(em_io_rec_type)
            expansion_module_id::em_qt16: em_qt16_config(em_io_rec_type)
            expansion_module_id::em_qr16: em_qr16_config(em_io_rec_type)
            expansion_module_id::em_dp01: em_dp01_config(em_io_rec_type)

  # digital expansion modules

  em_io_rec_01:
    seq:
      - id: len
        type: u2
      - id: records
        type: u4
        repeat: expr
        repeat-expr: len
      - type: u4
        valid: 0x01
      - type: u2
        valid: 0x0100

  em_io_rec_02:
    seq:
      - id: len
        type: u2
      - id: records
        type: u2
        repeat: expr
        repeat-expr: len
      - type: u4
        valid: 0x01
      - type: u2
        valid: 0x0100

  em_de08_config:
    params:
      - id: rec_type
        type: u1
        # should be 02, manually validate
    seq:
      - id: digital_input_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_de16_config:
    params:
      - id: rec_type
        type: u1
        # should be 02, manually validate
    seq:
      - id: digital_input_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_dt08_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: digital_output_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_qt16_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: digital_output_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_dr08_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: digital_output_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_qr16_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: digital_output_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_dt16_config:
    params:
      - id: rec_type
        type: u1
        # should be 02, manually validate
    seq:
      - id: digital_input_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01
      - id: digital_output_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_dr16_config:
    params:
      - id: rec_type
        type: u1
        # should be 02, manually validate
    seq:
      - id: digital_input_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01
      - id: digital_output_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_dt32_config:
    params:
      - id: rec_type
        type: u1
        # should be 02, manually validate
    seq:
      - id: digital_input_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01
      - id: digital_output_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  em_dr32_config:
    params:
      - id: rec_type
        type: u1
        # should be 02, manually validate
    seq:
      - id: digital_input_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01
      - id: digital_output_config
        type:
          switch-on: rec_type
          cases:
            0x02: em_io_rec_02
            0x01: em_io_rec_01

  # analog expansion modules

  em_ai_rec:
    seq:
      - id: len
        type: u4
      - id: records
        size: 26
        repeat: expr
        repeat-expr: len
      - type: u4
        valid: 0x01
      - type: u2
        # valid: 0x0100
      - type: u1
        valid: 01

  em_aq_rec:
    seq:
      - id: len
        type: u4
      - id: records
        size: 6
        repeat: expr
        repeat-expr: len
      - type: u4
        valid: len
      - type: u4
        valid: 0x01
      - type: u2
        valid: 0x0100

  em_ae04_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: analog_input_config
        type: em_ai_rec

  em_ae08_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: analog_input_config
        type: em_ai_rec

  em_aq02_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: analog_output_config
        type: em_aq_rec

  em_aq04_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: analog_output_config
        type: em_aq_rec

  em_am03_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: analog_input_config
        type: em_ai_rec
      - id: analog_output_config
        type: em_aq_rec

  em_am06_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: analog_input_config
        type: em_ai_rec
      - id: analog_output_config
        type: em_aq_rec

  # temperature expansion modules

  em_temp_rec:
    seq:
      - id: len
        type: u4
      - id: records
        size: 26
        repeat: expr
        repeat-expr: len
      - type: u4
        valid: 0x01
      - type: u2
        valid: 0x0100

  em_ar02_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: temp_input_config
        type: em_temp_rec

  em_ar04_config:
    params:
      - id: rec_type
        type: u1
        # should be 01, manually validate
    seq:
      - id: temp_input_config
        type: em_temp_rec

  em_at04_config:
    params:
      - id: rec_type
        type: u1
        # should be 00, manually validate
    seq:
      - id: temp_input_config
        type: em_temp_rec

  em_at08_config:
    params:
      - id: rec_type
        type: u1
        # should be 00, manually validate
    seq:
      - id: temp_input_config
        type: em_temp_rec

  # communication expansion modules

  em_dp01_config:
    params:
      - id: rec_type
        type: u1
        # should be 02, manually validate
    seq:
      - id: unknown_config
        type: em_io_rec_02
      - id: unknown_config2
        type: em_io_rec_01


enums:

  configured_notconfigured:
    0x01: configured
    0x00: not_configured

  freeze_nofreeze:
    0x01: freeze
    0x00: no_freeze

  expansion_module_id:
    0x80003000: em_de08
    0x80003001: em_dt08
    0x80003002: em_dr08
    0x80003003: em_dt16
    0x80003004: em_dr16
    0x80003005: em_dt32
    0x80003006: em_dr32
    0x80003007: em_ae04
    0x80003008: em_aq02
    0x80003009: em_am06
    0x80003010: em_ar02
    0x80003011: em_at04
    0x80003012: em_am03
    0x80003013: em_ae08
    0x80003014: em_ar04
    0x80003015: em_aq04
    0x80003016: em_de16
    0x80003017: em_qt16
    0x80003018: em_qr16
    0x80004001: em_dp01

  module_number:
    0: em_00
    1: em_01
    2: em_02
    3: em_03
    4: em_04
    5: em_05
    6: em_06
    7: em_07
    8: em_08
    9: em_09
    10: em_10
    11: em_11
    12: em_12
    13: em_13
    14: em_14
    15: em_15
