meta:
  id: symbol_table
  endian: le
  imports:
    - smart_types


seq:
  # - size: 0x1853
  # - size: 0x37b3
  # - size: 0xadf1
  # - size: 0x69f69

  - id: file_version
    type: u1
    doc: |
      1 byte version
      06: R02.04.00.00
      05: R01.00.00.00 (SMART) & R04.00 (MWP)
  - id: num_symbol_tables
    type: u2
  - id: symbol_tables
    type: symbol_table1
    repeat: expr
    repeat-expr: num_symbol_tables


types:
  symbol_table1:
    seq:
      - id: table_version
        type: u1
        doc: |
          1 byte version
          08: R02.04.00.00
          07: R01.00.00.00
      - id: table_type_id
        type: u2
        enum: table_type_enum
      - id: zeros_2b
        type: u2
      - id: table_index
        type: u2
      - id: table_subtype
        type: u2
        enum: table_subtype_enum
      - id: null_bytes
        size: 'table_version == 8 ? 22 : 18'
        type: str
        encoding: ASCII
      - id: marker_0200
        type: u2
        valid: 2
      - id: table_name
        type: smart_types::strl
      - id: hash_maybe_protection
        size: 18
      - id: allocated_memory_offset
        type: u4
        # ff ff ff ff means not allocated
      - id: num_entries
        type: u2
      - id: entries
        type: symbol_entry
        repeat: expr
        repeat-expr: num_entries

  symbol_entry:
    seq:
      - id: entry_index
        type: u2
      - id: entry_marker
        type: u2
        valid: 0x0002
      - id: symbol_name
        type: smart_types::strl

      - id: null1
        type: u1
        valid: 0
      - id: type2
        type: u1
        enum: type2
      - id: type3
        type: u1
        enum: type3
      - id: data_type
        type: u1
        enum: data_type

      - id: data_width
        type: u1
        enum: data_width
        # if: type3 != type3::unknown
        # not sure if this is the right conditional to comment out
      - id: memory_area
        type: u1
        enum: memory_area
        if: type3 != type3::unknown

      - id: memory_location_flag
        type: u2
        enum: memory_location_enum
        if: type2 == type2::memory_address
      - id: zero_byte_mem
        type: u1
        valid: 0
        if: type2 == type2::memory_address

      - id: data_or_offset
        type: u4

      - id: string_constant_data
        type: smart_types::strl1
        if: data_type == data_type::string_constant

      - id: zeros_1b
        type: u1
      - id: zeros_3b
        type: smart_types::nulls(3)
        if: type2 == type2::memory_address
      - id: zeros_4b
        type: smart_types::nulls(4)
        if: type2 == type2::constant

      - id: mem_area_desc1
        type: u2
        enum: mem_area_desc1_enum
        if: type2 != type2::incomplete
      - id: mem_area_desc2
        type: u2
        enum: mem_area_desc2_enum
        if: type2 != type2::incomplete

      - id: zero_byte_after_desc
        type: u1
        valid: 0
        if: data_type != data_type::string_constant

      - id: comment
        type: smart_types::strl

      - id: marker_after_comment
        type: u2
        valid: 2

      - id: invalid_addr_str
        type: smart_types::strl

      - id: entry_flags
        type: u2
        enum: symbol_entry_flags_enum


enums:
  table_type_enum:
    0x0bb8: symbol_table
    0x0bb9: pou_symbols
    0x0bba: library_symbol_table

  table_subtype_enum:
    0x0001: standard_symbol_table
    0x0002: library_symbol_table
    0x0800: pou_symbols_r01
    0x8000: pou_symbols_r02

  type2:
    0x00: constant
    0x01: memory_address
    0x03: incomplete

  type3:
    0x00: unknown
    0x01: constant_type
    0x02: memory_address_type

  data_type:
    0x00: memory_address
    0x01: positive_constant
    0x02: negative_constant
    0x03: invalid_memory_address
    0x04: hexadecimal_constant
    0x05: binary_constant
    0x06: ascii_constant
    0x07: real_constant
    0x08: string_constant

  data_width:
    0x01: data_width_1bit
    0x02: data_width_1byte
    0x04: data_width_2bytes
    0x08: data_width_4bytes
    0x10: data_width_string
    0x40: data_width_invalid_memory_address

  memory_area:
    0x00: area_sm_pou_incomplete_invalid_hc_ac_s
    0x01: area_constant_i
    0x02: area_q
    0x04: area_ai
    0x08: area_aq
    0x10: area_v
    0x20: area_m
    0x40: area_t
    0x80: area_c

  memory_location_enum:
    0x0000: loc_c_ai_aq_v_m_i_vd_invalid_none
    0x0001: loc_hc
    0x0002: loc_sm
    0x0004: loc_s
    0x0010: loc_ac
    0x0800: loc_main_pou

  mem_area_desc1_enum:
    # # For memory addresses
    # 0x0000: desc_main_pou
    # 0x0200: desc_bit
    # 0x0400: desc_byte
    # 0x4800: desc_word
    # 0x9010: desc_dword
    # 0x4A00: desc_timer
    # For constants
    0x0000: desc_string_const
    0x8000: desc_negative_dint_const
    0xC000: desc_negative_int_const
    # 0xC000: desc_negative_byte_const
    0xDE00: desc_bit_const
    0xDC00: desc_byte_const
    0xD800: desc_small_int_const
    # 0xDC00: desc_bin_byte_const
    0xD810: desc_hex_int_const
    0x9800: desc_int_const
    0x9000: desc_small_dint_const
    0x1000: desc_dint_const
    0x0400: desc_1byte_ascii
    0x4800: desc_2byte_ascii
    # 0x9000: desc_4byte_ascii

  mem_area_desc2_enum:
    # # For memory addresses
    # 0x6000: desc_bit_or_timer
    # 0x1400: desc_byte_1
    # 0x0400: desc_byte_2
    # 0x0000: desc_word_dword
    # 0x0200: desc_main_pou
    # For constants
    0x0000: desc_negative_constant
    0x0400: desc_negative_byte_constant_alt
    0x1400: desc_bit_const_1
    # 0x0400: desc_bit_const_2
    # 0x1400: desc_byte_const
    # 0x0400: desc_bin_byte_const
    # 0x0000: desc_hex_int_const
    # 0x0000: desc_small_int_const
    # 0x0000: desc_int_const
    # 0x0000: desc_small_dint_const
    # 0x0000: desc_dint_const
    0x1000: desc_real_constant
    # 0x1000: desc_string_const

  symbol_entry_flags_enum:
    0x0000: flag_standard
    0x0800: flag_no_name
    0x1000: flag_invalid_or_duplicate
    0x2000: flag_name_only
    0x2A00: flag_comment_only
    0x3000: flag_invalid_const_invalid_value
























