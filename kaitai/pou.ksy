meta:
  id: pou
  endian: le
  imports:
    - smart_types


seq:
  # - size: 0x076b
  # - size: 0x0be8
  # - size: 0x0ba4
  # - size: 0x0b78
  # - size: 0x0a76
  # - size: 0x0af7
  # - size: 0x088c
  # - size: 0x22cdf
  # - size: 0x85ebb
  # - size: 0x18311
  # - size: 0x19ac5

  - id: version
    type: u1

  - id: pou_type
    type: u4
    enum: pou_type

  - id: index
    type: u2

  - type: u4
    # valid: 1
    # this may be related to encryption
    # 0x00000001: no encryption
    # 0x00001100: encryption
    # 0x00000002: imported POU, not encrypted
    # imported means imported from library

  - type: smart_types::unknown(16)
    # this is null if native POU
    # this is not null if imported POU

  - id: editor_open
    type: u4
    enum: editor_open
    if: version > 7

  - id: block_version
    type: u2
    # 83 00: R03.01.00.00
    # 80 00: R02.04.00.00 with password protection
    # 0D 00: R02.04.00.00
    # 0B 00: R01.00.00.00

  - id: name
    type: smart_types::strl

  - type: u1
    valid: 0

  - id: comment
    type: smart_types::strl
    # always zero length on R02.04.00.00

  - type: u1
    valid: 0

  - id: author
    type: smart_types::strl

  - id: protection
    type:
      switch-on: block_version
      cases:
        0x0083: protection_v3
        0x0080: protection_v3
        0x000d: protection_v2
        0x000b: protection_v1

  - id: timestamp_created
    type: smart_types::timestamp

  - id: timestamp_modified
    type: smart_types::timestamp

  - type: u1
    valid: 0

  - id: network_count
    type: u2

  - id: network
    type: network
    repeat: expr
    repeat-expr: network_count

  - type: u1
    valid: 0
    if: block_version != 0x0083

  # symbol table comes AFTER networks
  - id: symbol_count
    type: u2
    if: block_version != 0x0083

  - id: symbols
    type: pou_symbol
    repeat: expr
    repeat-expr: symbol_count
    if: block_version != 0x0083

  - type: u4
    valid: 0

  - type: u4
    valid: 1

  - type: u4
    # valid: 100 = 0x64
    # sometimes 42 = 0x2a

  - id: version2
    type: u1
    valid: version
    if: block_version == 0x0083

  - size: 30
    if: block_version == 0x0083

  - id: xml_len
    type: u4
    if: block_version == 0x0083

  - id: variable_table_xml
    size: xml_len
    if: block_version == 0x0083

  - type: u2
    valid: 0x0101
    if: block_version == 0x0083

  - type: smart_types::rec(4,10)
    if: block_version == 0x0083


types:

  network:
    seq:
      - id: index
        type: u2

      - id: network_type
        type: u2
        valid:
          any-of: [0x0102, 0x0106]
        # 0x0102: regular network, or ladder network?
        # 0x0106: network in password-protected imported POU
        #         , or STL network?

      - id: version
        type: u2
        # 07 00 -> R03.01.00.00
        # 04 00 -> R02.04.00.00 & R01.00.00.00

      - id: title
        type: smart_types::strl

      - type: smart_types::null1

      - id: comment
        type: smart_types::strl

      - id: block_version
        type: u1
        # 02: R03.01.00.00
        # 01: R02.04.00.00 & R01.00.00.00

      - type: u4
        valid: 0
        if: block_version == 2

      - type: u1
        # valid: 2
        # sometimes 0 in the case of encrypted? wizard POU
        # if: block_version == 2
      - type: u2
        # valid: 0
      - id: unknown_count
        type: u2
        # valid: 0
        # usually 0, sometimes 3 (encrypted? wizard POU)


      # unknown records
      - id: unknown_data
        type: unknown_data
        repeat: expr
        repeat-expr: unknown_count





      - type: u1
        # valid: 2
        # usually 2
        # in the case of a password-protected imported POU, this is 6
        # might be a bit field

      - id: bookmark
        type: u4
        enum: bookmark_nobookmark

      - type: u2
        valid: 0

      - id: stl_count
        type: u2

      # STL only present if network has been compiled
      # otherwise stl_count = 0
      - id: stl
        type: stl
        repeat: expr
        repeat-expr: stl_count

      - type: u1
        valid: 1



      - id: cell_count
        type: u2
        if: network_type == 0x0102

      - id: cell
        type: cell
        repeat: expr
        repeat-expr: cell_count
        if: network_type == 0x0102

      - id: stl_line_count
        type: u2
        if: network_type == 0x0106

      - id: stl_line
        type: stl_line
        repeat: expr
        repeat-expr: stl_line_count
        if: network_type == 0x0106

  unknown_data:
    seq:
      - id: unknown_index
        type: u2
      - type: u2
        valid: 0x0302
        if: unknown_index != 0xffff
      - type: u1
        if: unknown_index != 0xffff
      - type: u4
        if: unknown_index != 0xffff
      - type: smart_types::strl
        if: unknown_index != 0xffff



  stl:
    seq:
      - id: index
        type: u2
      - type: u2
        valid: 0
      - id: stl_opcode
        type: u2
        enum: stl_opcode
      - size: 2
        contents: [0x01, 0x01]

      - id: stl_arg_count
        type: u2
      - id: stl_arg
        type: stl_arg
        repeat: expr
        repeat-expr: stl_arg_count


  stl_line:
    seq:
      - id: index
        type: u2
      - type: u2
        valid: 0x0104
      - type: u2
        valid: 0
      - id: stl_opcode
        type: u2
        enum: stl_opcode
      - size: 4
        # only in uncompiled
      - size: 2
        contents: [0x01, 0x01]

      - id: stl_arg_count
        type: u2
      - id: stl_arg
        type: stl_line_arg
        repeat: expr
        repeat-expr: stl_arg_count






  stl_arg:
    seq:
      - id: index
        type: u2
      - type: u1
        # valid: 1
        # usually 1, sometimes 0
      - type: u2
        valid: 0x0103
      - type: u4
        valid: 0
      - type: u1
        valid: 1
      - type: u4
        valid: 0
      - id: token_form
        type: u1
        # valid:
        #   any-of: [1, 2]
        enum: token_form

      - id: is_pointer
        type: u1
        valid:
          any-of: [0, 1, 2]
        if: token_form == token_form::identifier
        # 0: not pointer
        # 1: pointer to VB
        # 2: pointer to VD ?
      - id: data_type
        type: u1
        enum: data_type_short
        if: token_form == token_form::identifier
      - id: arg_type
        type: u1
        enum: arg_type
        if: token_form == token_form::identifier
      - id: arg_class
        type: u2
        enum: var_class
        if: token_form == token_form::identifier
        # looks like type & bit field
        # sometimes 0x02, sometimes 0x20
        # Always_On: 0x02
        # I123.4, T37 (bit): 0x00
        # unknown: 0x20 -> data_type = 1, arg_type = 0, offset = 480
        # unknown: 0x20
        # 0x200 -> imported MBUS_INIT, data_type = 4, arg_type = 0, offset = 10 (SBR10)
      - type: u1
        valid: 0
        if: token_form == token_form::identifier
      - id: offset_or_pou_number
        type: u4
        if: token_form == token_form::identifier
        # looks like type & offset for subroutine?
        # but not for contacts

      - id: token_type
        type: u1
        enum: token_type
        if: token_form == token_form::literal
      - id: mem_width
        type: u1
        enum: mem_width
        if: token_form == token_form::literal
      - id: unknown_flag
        type: u1
        if: token_form == token_form::literal
      - id: value_integer
        type: u4
        if: >
          token_form == token_form::literal
          and (token_type == token_type::unsigned_integer
               or token_type == token_type::signed_integer)
      - id: value_float
        type: f4
        if: >
          token_form == token_form::literal
          and token_type == token_type::floating_point
      - id: value_string
        type: smart_types::strl1
        if: >
          token_form == token_form::literal
          and (token_type == token_type::string
               or token_type == token_type::identifier)
      - type: u1
        if: unknown_flag == 1




  stl_line_arg:
    seq:
      - id: index
        type: u2
      - type: u1
        valid:
          any-of: [0, 1, 2]
        # type or version
        # usually 1, sometimes 0, sometimes 2 (STL network)
        # STL network also sometimes 0
      - type: u2
        valid: 0x0103
      - type: u4
        valid: 0
      - type: u1
        valid: 1
      - type: u4
        valid: 0
      - id: token_form
        type: u1
        # valid:
        #   any-of: [1, 2]
        enum: token_form

      - id: is_pointer
        type: u1
        valid:
          any-of: [0, 1, 2]
        if: token_form == token_form::identifier
        # 0: not pointer
        # 1: pointer to VB
        # 2: pointer to VD ?
      - id: data_type
        type: u1
        enum: data_type_short
        if: token_form == token_form::identifier
      - id: arg_type
        type: u1
        enum: arg_type
        if: token_form == token_form::identifier
      - id: arg_class
        type: u2
        enum: var_class
        if: token_form == token_form::identifier
        # looks like type & bit field
        # sometimes 0x02, sometimes 0x20
        # Always_On: 0x02
        # I123.4, T37 (bit): 0x00
        # unknown: 0x20 -> data_type = 1, arg_type = 0, offset = 480
        # unknown: 0x20
        # 0x200 -> imported MBUS_INIT, data_type = 4, arg_type = 0, offset = 10 (SBR10)
      - type: u1
        valid: 0
        if: token_form == token_form::identifier
      - id: offset_or_pou_number
        type: u4
        if: token_form == token_form::identifier
        # looks like type & offset for subroutine?
        # but not for contacts

      - id: token_type
        type: u1
        enum: token_type
        if: token_form == token_form::literal
      - id: mem_width
        type: u1
        enum: mem_width
        if: token_form == token_form::literal
      - type: u1
        if: token_form == token_form::literal
      - id: value_integer
        type: u4
        if: >
          token_form == token_form::literal
          and (token_type == token_type::unsigned_integer
               or token_type == token_type::signed_integer)
      - id: value_float
        type: f4
        if: >
          token_form == token_form::literal
          and token_type == token_type::floating_point
      - id: value_string
        type: smart_types::strl1
        if: >
          token_form == token_form::literal
          and (token_type == token_type::string
               or token_type == token_type::identifier)

      - type: u1
        valid: 0
        if: >
          token_form == token_form::literal
          and token_type != token_type::identifier









  cell:
    seq:
      - type: smart_types::null1

      - id: row
        type: u1

      - id: col
        type: u1

      - type: u2
        valid: 0x0103

      - id: cell_type
        type: u2
        enum: cell_type

      - type: u1
        # usually 0, sometimes but rarely 1

      - id: cell_subtype
        type: u1
        enum: cell_subtype

      - id: vertical_lines_right_side
        type: u1
        # this is a bit field
        enum: vertical_lines

      - id: cell_flags
        type: u2
        enum: cell_flags

      - id: label_line_count
        type: u1

      - id: label_l_r
        type: label_l_r
        repeat: expr
        repeat-expr: label_line_count
        # label is the inside of the box or element

      - type: u2
        valid: 0x0101

      - id: arg_count
        type: u2

      - id: arg
        type: arg
        repeat: expr
        repeat-expr: arg_count
        # arg is the given value or symbol/identifier

  label_l_r:
    seq:
      - type: smart_types::null1

      - id: label_l
        type: strz
        size: 24
        encoding: ASCII
        # 1st
        # box label, or first label on the left side
        # 2nd
        # contact/coil label, or second label on the left side
        # 3rd
        # third label on the left side

      - id: type_l
        type: u2
        # 1st
        # 0x0001: box top or subroutine, others
        # 0x0200: box second or next parts (continuation)
        # 2nd
        # 0x0001: box top or subroutine, others
        # 0x0201: NOP box
        # 0x0200: box second half or next parts (continuation)
        # 3rd
        # 0x0100: subroutine, others
        # 0x0200: box second half or next parts (continuation)

      - id: label_r
        type: strz
        size: 24
        encoding: ASCII
        # 1st
        # first label on the right side
        # 2nd
        # second label on the right side
        # 3rd
        # third label on the right side

      - id: type_r
        type: u2
        # 1st
        # 0x0001: box top or subroutine, XMT box second half, others
        # 0x0200: box second or next parts (continuation)
        # 2nd
        # 0x0001: box second half, others
        # 0x0202: box top half or subroutine last part
        # 3rd
        # 0x0001: usually
        # 0x0202: box last part

  arg:
    seq:
      - id: index
        type: u2

      - id: value
        type: value
        if: index != 0xffff

  value:
    seq:
      - id: value_type
        type: u2
        # 0x0300: string
        # 0x0301: ...?
        # 0x0302: string?
        # 0x0300: number?

      - type: u1
        # 01 normal
        # 00 ENO ...???

      - type: u4
        # valid: 0
        # sometimes 2

      - type: u1
        valid: 1

      - type: u4
        valid: 0

      - id: token_form
        type: u1
        enum: token_form
        # 01: literal
        # 02: identifier

      - id: token_type
        type: u1
        enum: token_type

      - id: mem_type
        type: u1
        enum: mem_width

      - id: arg_type
        type: u1
        enum: arg_type

      - type: u4
        if: token_type == token_type::string

      - id: value_str
        type: smart_types::strl1
        if: >
          (token_type == token_type::identifier
          or token_type == token_type::string)
          and token_form == token_form::literal

      - id: value_int
        type: u4
        if: >
          token_type == token_type::unsigned_integer
          or token_type == token_type::signed_integer

      - type: u1
        valid: 0
        if: >
          (token_type == token_type::unsigned_integer
          or token_type == token_type::signed_integer)
          and token_form == token_form::literal

      - id: value_float
        type: f4
        if: token_type == token_type::floating_point

      - type: u1
        valid: 0
        if: token_type == token_type::floating_point

      - type: u1
        if: token_form == token_form::identifier
        # usually 0, but 4 when SCR bit

      - type: smart_types::nulls(2)
        if: token_form == token_form::identifier

      - id: offset
        type: u4
        if: >
          token_type != token_type::unsigned_integer
          and token_type != token_type::signed_integer
          and token_form == token_form::identifier

  cell_value:
    seq:
      - id: type
        type: u2

      - id: raw
        type: u4

  pou_symbol:
    seq:
      - id: marker
        type: u2

      - id: name
        type: smart_types::strl

      - type: u1
        valid: 0

      - id: status_flags
        type: u2
        # 0x0201 if complete
        # 0x0003 if incomplete

      - type: u1
        valid: 0

      - id: data_type_short
        type: u2
        if: status_flags != 3
        enum: data_type_short

      - id: var_class
        type: u1
        if: status_flags != 3
        enum: var_class

      - type: u2
        valid: 0

      - id: offset
        type: u4
        if: status_flags != 3

      - type: u4
        valid: 0
        if: status_flags != 3

      - id: data_type_long
        type: u4
        enum: data_type_long

      - type: u1
        valid: 0

      - id: comment
        type: smart_types::strl

      - type: u1
        valid: 2

      - id: var_type
        type: u1
        enum: var_type

      - id: bitfield
        type: u2

      - id: extra
        type: u2

      - id: size_code
        type: u1

      - id: status
        type: var_status

      - id: zero4
        type: u1

  protection_v3:
    seq:
      - id: salt
        size: 2
      - size: 20
      - id: sha512
        size: 64
      - id: len1
        type: u4
      - id: hash1
        size: len1
      - id: len2
        type: u4
      - id: encrypted_network_data
        size: len2
      - type: smart_types::nulls(3)

  protection_v2:
    seq:
      - id: salt
        type: u2
      - type: smart_types::nulls(20)
      - id: sha512
        size: 64
        # this is sha512 of password+salt
      # - type: smart_types::nulls(3)
      - type: smart_types::null1
      - type: u1
        # usually 0
        # is 1 when imported POU
      # - type: smart_types::null1
      - type: u1
        # usually 0
        # 2 when password-protected imported POU

  protection_v1:
    seq:
      - size: 22
      - type: smart_types::nulls(3)

  var_status:
    meta:
      bit-endian: be
    seq:
      - id: unknown0
        type: b1
      - id: unknown1
        type: b1
      - id: incomplete
        type: b1
      - id: invalid
        type: b1
      - id: missing_name
        type: b1
      - id: unknown2
        type: b1
      - id: missing_type
        type: b1
      - id: is_variable
        type: b1


enums:
  pou_type:
    0x03e8: main
    0x03e9: sbr
    0x03ea: int
    0x03eb: fb

  editor_open:
    0x01: open
    0x00: closed

  bookmark_nobookmark:
    0x01: bookmark
    0x00: nobookmark

  cell_type:
    0x0000: arrow_or_empty
    0x0001: horizontal_line
    0x0014: no_contact
    0x0015: nc_contact
    0x0018: not
    0x0019: positive_transition
    0x001a: negative_transition
    0x001b: output_coil
    0x001d: set_coil
    0x0020: reset_coil
    0x0023: nop
    0x00a0: xmt
    0x0149: lpf
    0x014a: add_r
    0x0159: add_i
    0x01a0: mov_w
    0x03e9: subroutine

  cell_subtype:
    0x07: final_arrow
    0x06: dangling_arrow
    0x05: horizontal_line
    0x04: coil
    0x03: contact
    0x02: box
    0x01: box_with_power_in
    0x00: vertical_line

  cell_flags:
    0x0600: box_bottom
    0x0002: box_top

  vertical_lines:
    0x03: up_down
    0x02: down
    0x01: up
    0x00: none

  var_type:
    0x00: in
    0x01: in_out
    0x02: out
    0x03: temp

  data_type_long:
    0x80000002: power_flow
    0x00000002: bool
    0x00040004: byte
    0x00000048: word_or_int
    0x00000090: dword_or_dint
    0x00000010: dword_sometimes
    0x00001000: real
    0x00100000: string
    0x00000000: no_type

  data_type_short:
    0x0000: power_flow
    0x0001: bool
    0x0002: byte
    0x0004: word_or_int
    0x0008: dword_or_dint_or_real_or_string
    # maybe number of bytes? but why is string 0x0008?

  var_class:
    0x00: power_flow
    0x20: local_variable

  arg_type:
    0x00: invalid_or_l_sm_pou_hc_ac_scr_memory
    0x01: literal_or_i_memory
    0x02: q_memory
    0x04: ai_memory
    0x08: aq_memory
    0x10: v_memory
    0x20: m_memory
    0x40: t_memory
    0x80: c_memory

  mem_width:
    0x01: bit_or_some_text
    0x02: byte
    0x04: word
    0x08: dword
    0x10: string

  token_type:
    0x00: identifier
    0x01: unsigned_integer
    0x02: signed_integer
    0x07: floating_point
    0x08: string

  token_form:
    0x01: literal
    0x02: identifier

  # opcodes for the same instruction in STL and LAD are different
  # for example:
  # - STL -- ADD_R is 0x02c6
  # - LAD -- ADD_R is 0x014a
  stl_opcode:
    0x01fe: ld # NO contact
    0x0214: eq # = / output
    0x03e9: call
    0x0321: scre
    0x031c: next
    0x0211: lps
    0x0202: an # NC contact
    0x0205: ai # NO contact immediate
    0x0208: ani # NC contact immediate
    0x0244: ab_le
    0x0268: ad_le
    0x0256: aw_le
    0x027a: ar_le
    0x023e: ab_ne
    0x0262: ad_ne
    0x0250: aw_ne
    0x0274: ar_ne
    0x0286: as_ne
    0x024a: ab_lt
    0x026e: ad_lt
    0x025c: aw_lt
    0x0280: ar_lt
    0x023b: ab_eq
    0x025f: ad_eq
    0x024d: aw_eq
    0x0271: ar_eq
    0x0283: as_eq
    0x0241: ab_ge
    0x0265: ad_ge
    0x0253: aw_ge
    0x0277: ar_ge
    0x0247: ab_gt
    0x026b: ad_gt
    0x0259: aw_gt
    0x027d: ar_gt
    0x020d: ed # negative transition
    0x0213: lpp
    0x020a: not
    0x020b: eu # positive transition
    0x0148: eq_alt
    0x0157: eq_altp
    0x02f2: disi
    0x0325: end
    0x02f1: eni
    0x0215: eq_i # =I / output immediate
    0x031d: jmp
    0x0218: r # reset
    0x0323: cret
    0x02f0: creti
    0x0219: ri # reset immediate
    0x0216: s # set
    0x0320: scrt
    0x0217: si # set immediate
    0x0327: stop
    0x0328: wdr
    0x012a: absdi
    0x0129: absi
    0x012b: absr
    0x0349: att
    0x030e: movd
    0x02d6: add_d
    0x030d: movw
    0x02d5: add_i
    0x030f: movr
    0x02c6: add_r




































