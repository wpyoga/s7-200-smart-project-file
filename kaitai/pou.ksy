meta:
  id: pou
  endian: le
  bit-endian: be
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
  # - size: 0x19acp5
  # - size: 0x088d
  # - size: 0x0850
  # - size: 0x084e
  # - size: 0x1720
  # - size: 0x08ce9
  # - size: 0x5ebd
  # - size: 0x85ebb
  # - size: 0xcc30f
  # - size: 0x3548b
  # - size: 0x088c
  # - size: 0x2edfb
  # - size: 0x9099
  # - size: 0xede
  # - size: 0x90a1
  # - size: 0x90c8
  # - size: 0x15969
  # - size: 0x16afca
  # - size: 0x17ae43
  # - size: 0x0a73
  # - size: 0x8427
  # - size: 0x991c

  - id: version
    type: u1
    valid:
      any-of: [7, 8]

  - id: pou_type
    type: u4
    enum: pou_type

  - id: index
    type: u2

  - id: origin_and_protection
    type: u4
    # valid: 1
    # this may be related to encryption
    # 0x00000001: native POU, not password-protected
    # 0x00001100: encryption
    # 0x00000002: imported POU, not password-protected
    # 0x00000200: imported POU, password-protected, possible to enter password
    # 0x00000400: imported POU, password-protected, not possible to enter password
    #             or: wizard-created POU, not supposed to be edited
    # imported means imported from library
    # native means POU from this program

  # - id: protection
  #   type: u1

  # - id: origin
  #   type: u1

  # - type: u2

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
    # 82 00: R03.00.00.00
    # 80 00: R02.04.00.00 with password protection
    # 0D 00: R02.04.00.00
    # 0B 00: R01.00.00.00
    # 0A 00: R04.00 -> 4.0.0.46 -> MWP, not SMART
    # 01 00: empty, no data, related to encrypted POU without possibility to enter password

  - id: name
    type: smart_types::strl

  - id: content
    type: pou_content(version, block_version)
    if: name.len != 0

  - type: u4
    # valid: 0
    # sometimes 100 = 0x64
    if: name.len == 0

  - id: extra_data
    type: pou_extra_data(version, content.network_count)
    if: block_version == 0x0083


types:
  pou_content:
    params:
      - id: version
        type: u1
      - id: block_version
        type: u2
    seq:
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
            0x000a: smart_types::unknown(5)

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

      # this might be a dependency list
      # for an imported POU, if it has dependencies, it will pull those as well
      - id: dependency_count
        type: u4
      - type: u1
        valid: 0
        if: dependency_count > 0
      - id: dependency
        type: dependency(version)
        repeat: expr
        repeat-expr: dependency_count
        if: dependency_count > 0

      - id: usually_1
        type: u4
        # valid: 1
        # sometimes 0
        # if: dependency_count > 0

      - id: usually_0x64
        type: u4
        # valid: 100 = 0x64
        # sometimes 42 = 0x2a
        # if: dependency_count > 0


  dependency:
    params:
      - id: version
        type: u1
    seq:
      - type: smart_types::strl
      - id: version2
        type: u1
        valid: version
      - type: u2
        enum: pou_type
      - size: 8
      - id: hash
        size: 16
        # not sure what to hash, but sure looks like 128-bit hash
      - type: u4
        valid: 0

  # one for each network
  pou_extra_data:
    params:
      - id: version
        type: u1
      - id: network_count
        type: u4
    seq:
      - id: version2
        type: u1
        valid: version

      - id: fb_related
        type: u2
        valid:
          any-of: [0x0000, 0x32ca]
        # ca 32 seen on fb POU, 00 00 elsewhere
      - type: u4
        valid: 0
      - type: u2
        valid: 1
      - type: smart_types::nulls(22)

      - id: xml_len
        type: u4

      - id: variable_table_xml
        size: xml_len

      - type: u2
        valid: 0x0101

      - id: data_count
        type: u4
        valid: network_count

      - id: data_record
        type: data_record
        repeat: eos
        # lad, fbd: seems to be a collection of labels used by the POU
        #           labels for each FBD block
        #           how to determine number of records is unknown



  data_record:
    seq:
      - id: version
        type: u1
        valid: 2
      - id: cell_count
        type: u4
      - id: cell_label
        type: cell_label
        repeat: expr
        repeat-expr: cell_count

  cell_label:
    seq:
      - id: version
        type: u1
        valid: 4
      - id: label_pair_count
        type: u4
        # usually either 0 or 3
      - id: label_pair
        type: label_pair
        repeat: expr
        repeat-expr: label_pair_count
        # first label pair is the internal label of the box/cell
        # S_ITR '' -> this is label on top of subroutine box
        # EN '' -> second row of box, no output
        # Input Output -> third row of box, Input on left side, Output on right side
        # so far, label_pair_count is always either 3 or 0
        # in LAD, the 2nd and 3rd pairs describe the 2nd and 3rd rows of the cell
        # in FBD, the 2nd and 3rd pairs are always empty strings

  label_pair:
    seq:
      - id: fixed_1
        type: u1
        valid: 1
      - id: label_l
        type: smart_types::strl
      - id: label_r
        type: smart_types::strl


  network:
    seq:
      - id: index
        type: u2

      - id: network_type
        type: u2
        valid:
          any-of: [network_type::lad, network_type::stl, network_type::fbd]
        enum: network_type
        # 0x0101?: FBD network
        # 0x0102: LAD network
        # 0x0106: STL network

      - id: version
        type: u2
        # 07 00 -> R03.01.00.00
        # 04 00 -> R02.04.00.00 & R01.00.00.00

      - id: title
        type: smart_types::strl

      - type: smart_types::null1

      - id: comment
        type: smart_types::strl





      - id: network_version
        type: u1
        # 02: R03.01.00.00
        # 01: R02.04.00.00 & R01.00.00.00

      # - type: u4
      #   valid: 0
      #   if: network_version == 2

      - id: line_status_count
        # type: u2
        # if: network_type == network_type::stl
        # if: network_version == 1
        type:
          switch-on: network_version
          cases:
            1: u2
            2: u4

      - id: line_status
        type: line_status(network_version)
        repeat: expr
        repeat-expr: line_status_count
        # if: network_type == network_type::stl
        # usually just 0xffff

      - type: u1
        # valid: 0
        # usually 0 when network_version == 1
        # 2 when network_version == 2

      - id: line_comment_count
        # type: u2
        # valid: line_status_count
        # sometimes (value is 3) not equal to line_status_count (value is 0)
        # if: network_type == network_type::stl
        # if: network_version == 1
        type:
          switch-on: network_version
          cases:
            1: u2
            2: u4

      # unknown records
      - id: line_comment_data
        type: line_comment_data(network_version)
        repeat: expr
        repeat-expr: line_comment_count
        # if: network_type == network_type::stl

      - id: usually_2
        type: u1
        # valid: 2
        # usually 2
        # 6: password-protected imported POU, no possibility to enter password
        # might be a bit field
        # 1: native FBD

      - id: bookmark
        type: u4
        enum: bookmark_nobookmark

      - type: u2
        valid: 0

      # user input (LAD, FBD, STL) is converted to compiled STL during compilation
      # comments are not included in this list

      - id: compiled_stl_count
        type: u2

      - id: compiled_stl
        type: stl_combi(true)
        repeat: expr
        repeat-expr: compiled_stl_count

      - id: fixed1
        type: u1
        valid: 1
        # if: network_type != network_type::fbd

      # - id: fixed1_fbd
      #   type: u1
      #   valid: 1
      #   if: network_type == network_type::fbd

      # the following contains raw network data
      # i.e. what the user has typed in, inside the application

      - id: lad_cell_count
        type: u2
        if: network_type == network_type::lad
      - id: lad_cell
        type: lad_cell
        repeat: expr
        repeat-expr: lad_cell_count
        if: network_type == network_type::lad

      - id: stl_line_count
        type: u2
        if: network_type == network_type::stl
      - id: stl_line
        type: stl_combi(false)
        repeat: expr
        repeat-expr: stl_line_count
        if: network_type == network_type::stl

      - id: fbd_cell_count
        type: u2
        if: network_type == network_type::fbd
      - id: fbd_cell
        type: fbd_cell
        repeat: expr
        repeat-expr: fbd_cell_count
        if: network_type == network_type::fbd






  line_status:
    params:
      - id: network_version
        type: u1
    seq:
      - id: index
        # type: u2
        type:
          switch-on: network_version
          cases:
            1: u2
            2: u4
        # index, or 0xffff if invalid
      - type: u1
        if: index != 0xffff
        # might be: 0 for string, 1 for number
      - id: line_content
        type: smart_types::strl
        if: index != 0xffff

  line_comment_data:
    params:
      - id: network_version
        type: u1
    seq:
      - id: index
        # type: u2
        type:
          switch-on: network_version
          cases:
            1: u2
            2: u4
        # index, or 0xffff if invalid
      - type: u1
        if: index != 0xffff
      - type: u1
        valid:
          any-of: [1, 2, 3, 6, 7]
        if: index != 0xffff
      - type: u1
        if: index != 0xffff
      - type: u4
        if: index != 0xffff
      - type: smart_types::strl
        if: index != 0xffff





  stl_combi:
    params:
      - id: compiled
        type: bool
    seq:
      - id: index
        type: u2
      - id: stl_content
        type: stl_content(compiled)
        if: index != 0xffff
        # if index is 0xffff, the line consists of only comment or is empty

  stl_content:
    params:
      - id: compiled
        type: bool
    seq:
      - id: type
        type: u2
        valid: 0x0104
        if: not compiled
      - type: u2
        valid: 0
      - id: stl_opcode
        type: u2
        enum: stl_opcode
      - size: 4
        if: not compiled
      - size: 2
        contents: [0x01, 0x01]

      - id: stl_arg_count
        type: u2
      - id: stl_arg
        type: stl_arg_combi(compiled)
        repeat: expr
        repeat-expr: stl_arg_count

  stl_arg_combi:
    params:
      - id: compiled
        type: bool
    seq:
      - id: index
        type: u2

      - type: u1
        valid:
          any-of: [0, 1, 2]
        if: compiled
        # usually 1, sometimes 0, sometimes 2
      - type: u1
        valid:
          any-of: [0, 1, 2]
        if: not compiled
        # type or version
        # usually 1, sometimes 0, sometimes 2 (STL network)
        # STL network also sometimes 0

      - id: stl_arg_type
        type: u2
        valid:
          any-of: [0x0103, 0x0104]
        # 0x0103 found on V3
      - type: u4
        valid: 0
      - type: u1
        valid: 1

      - id: col_number
        type: u4
        # column number, useful for original STL
        # encodes the position of each argument in the line
        # sometimes still present even after compilation

      - id: token_form
        type: u1
        valid:
          any-of: [token_form::literal, token_form::identifier]
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
      - id: arg_type_identifier
        type: u1
        enum: arg_type
        if: token_form == token_form::identifier
      - id: arg_class
        type: u1
        enum: var_class
        if: token_form == token_form::identifier
        # looks like type & bit field
        # sometimes 0x02, sometimes 0x20
        # Always_On: 0x02
        # I123.4, T37 (bit): 0x00
        # unknown: 0x20 -> data_type = 1, arg_type = 0, offset = 480
        # unknown: 0x20
        # 0x200 -> imported MBUS_INIT, data_type = 4, arg_type = 0, offset = 10 (SBR10)
      - type: u2
        # valid: 0
        # sometimes 2 when POU (subroutine call to POU 2 maybe?)
        if: token_form == token_form::identifier
      - id: offset_or_pou_number
        type: u4
        if: token_form == token_form::identifier
        # looks like type & offset for subroutine?
        # but not for contacts

      - id: fixed1_n2
        type: u2
        valid: 1
        if: >
          token_form == token_form::identifier
          and _parent._parent._parent.version == 7
        # and _root.content.network[0].version == 7




      - id: token_type
        type: u1
        enum: token_type
        if: token_form == token_form::literal
      - id: mem_width
        type: u1
        enum: mem_width
        if: token_form == token_form::literal
      # - id: unknown_flag
      - id: arg_type
        type: u1
        enum: arg_type
        if: token_form == token_form::literal
      - id: value_integer
        type: u4
        if: >
          token_form == token_form::literal
          and (token_type == token_type::unsigned_integer
               or token_type == token_type::signed_integer
               or token_type == token_type::binary
               or token_type == token_type::hexadecimal
               or token_type == token_type::string)
          and not arg_type == arg_type::invalid_or_hc_sm_scr_ac_l_pou_memory
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
               or token_type == token_type::identifier
               or arg_type == arg_type::invalid_or_hc_sm_scr_ac_l_pou_memory)

      - type: u1
        if: >
          arg_type == arg_type::literal_or_i_memory
          and compiled
          and token_type != token_type::string
      - type: u1
        valid: 0
        if: >
          token_form == token_form::literal
          and token_type != token_type::identifier
          and not compiled
          and arg_type != arg_type::invalid_or_hc_sm_scr_ac_l_pou_memory





















  # stl:
  #   seq:
  #     - id: index
  #       type: u2
  #     - type: u2
  #       valid: 0
  #     - id: stl_opcode
  #       type: u2
  #       enum: stl_opcode
  #     - size: 2
  #       contents: [0x01, 0x01]

  #     - id: stl_arg_count
  #       type: u2
  #     - id: stl_arg
  #       type: stl_arg
  #       repeat: expr
  #       repeat-expr: stl_arg_count


  # stl_line:  # uncompiled
  #   seq:
  #     - id: index
  #       type: u2
  #     - type: u2
  #       valid: 0x0104        # only in uncompiled
  #     - type: u2
  #       valid: 0
  #     - id: stl_opcode
  #       type: u2
  #       enum: stl_opcode
  #     - size: 4        # only in uncompiled
  #     - size: 2
  #       contents: [0x01, 0x01]

  #     - id: stl_arg_count
  #       type: u2
  #     - id: stl_arg
  #       type: stl_line_arg
  #       repeat: expr
  #       repeat-expr: stl_arg_count




  # stl_arg:
  #   seq:
  #     - id: index
  #       type: u2
  #     - type: u1
  #       # valid: 1
  #       # usually 1, sometimes 0
  #     - id: type
  #       type: u2
  #       valid: 0x0103
  #     - type: u4
  #       valid: 0
  #     - type: u1
  #       valid: 1
  #     - type: u4
  #       # valid: 0
  #       # sometimes 7
  #     - id: token_form
  #       type: u1
  #       # valid:
  #       #   any-of: [1, 2]
  #       enum: token_form

  #     - id: is_pointer
  #       type: u1
  #       valid:
  #         any-of: [0, 1, 2]
  #       if: token_form == token_form::identifier
  #       # 0: not pointer
  #       # 1: pointer to VB
  #       # 2: pointer to VD ?
  #     - id: data_type
  #       type: u1
  #       enum: data_type_short
  #       if: token_form == token_form::identifier
  #     - id: arg_type
  #       type: u1
  #       enum: arg_type
  #       if: token_form == token_form::identifier
  #     - id: arg_class
  #       type: u1
  #       enum: var_class
  #       if: token_form == token_form::identifier
  #       # looks like type & bit field
  #       # sometimes 0x02, sometimes 0x20
  #       # Always_On: 0x02
  #       # I123.4, T37 (bit): 0x00
  #       # unknown: 0x20 -> data_type = 1, arg_type = 0, offset = 480
  #       # unknown: 0x20
  #       # 0x200 -> imported MBUS_INIT, data_type = 4, arg_type = 0, offset = 10 (SBR10)
  #     - type: u2
  #       valid: 0
  #       if: token_form == token_form::identifier
  #     - id: offset_or_pou_number
  #       type: u4
  #       if: token_form == token_form::identifier
  #       # looks like type & offset for subroutine?
  #       # but not for contacts

  #     - id: token_type
  #       type: u1
  #       enum: token_type
  #       if: token_form == token_form::literal
  #     - id: mem_width
  #       type: u1
  #       enum: mem_width
  #       if: token_form == token_form::literal
  #     - id: unknown_flag
  #       type: u1
  #       if: token_form == token_form::literal
  #     - id: value_integer
  #       type: u4
  #       if: >
  #         token_form == token_form::literal
  #         and (token_type == token_type::unsigned_integer
  #             or token_type == token_type::signed_integer)
  #     - id: value_float
  #       type: f4
  #       if: >
  #         token_form == token_form::literal
  #         and token_type == token_type::floating_point
  #     - id: value_string
  #       type: smart_types::strl1
  #       if: >
  #         token_form == token_form::literal
  #         and (token_type == token_type::string
  #             or token_type == token_type::identifier)
  #     - type: u1
  #       if: unknown_flag == 1



  # stl_line_arg:
  #   seq:
  #     - id: index
  #       type: u2
  #     - type: u1
  #       valid:
  #         any-of: [0, 1, 2]
  #       # type or version
  #       # usually 1, sometimes 0, sometimes 2 (STL network)
  #       # STL network also sometimes 0
  #     - id: type
  #       type: u2
  #       valid: 0x0103
  #     - type: u4
  #       valid: 0
  #     - type: u1
  #       valid: 1
  #     - type: u4
  #       valid: 0
  #     - id: token_form
  #       type: u1
  #       # valid:
  #       #   any-of: [1, 2]
  #       enum: token_form

  #     - id: is_pointer
  #       type: u1
  #       valid:
  #         any-of: [0, 1, 2]
  #       if: token_form == token_form::identifier
  #       # 0: not pointer
  #       # 1: pointer to VB
  #       # 2: pointer to VD ?
  #     - id: data_type
  #       type: u1
  #       enum: data_type_short
  #       if: token_form == token_form::identifier
  #     - id: arg_type
  #       type: u1
  #       enum: arg_type
  #       if: token_form == token_form::identifier
  #     - id: arg_class
  #       type: u1
  #       enum: var_class
  #       if: token_form == token_form::identifier
  #       # looks like type & bit field
  #       # sometimes 0x02, sometimes 0x20
  #       # Always_On: 0x02
  #       # I123.4, T37 (bit): 0x00
  #       # unknown: 0x20 -> data_type = 1, arg_type = 0, offset = 480
  #       # unknown: 0x20
  #       # 0x200 -> imported MBUS_INIT, data_type = 4, arg_type = 0, offset = 10 (SBR10)
  #     - type: u2
  #       valid: 0
  #       if: token_form == token_form::identifier
  #     - id: offset_or_pou_number
  #       type: u4
  #       if: token_form == token_form::identifier
  #       # looks like type & offset for subroutine?
  #       # but not for contacts

  #     - id: token_type
  #       type: u1
  #       enum: token_type
  #       if: token_form == token_form::literal
  #     - id: mem_width
  #       type: u1
  #       enum: mem_width
  #       if: token_form == token_form::literal
  #     - type: u1
  #       if: token_form == token_form::literal
  #     - id: value_integer
  #       type: u4
  #       if: >
  #         token_form == token_form::literal
  #         and (token_type == token_type::unsigned_integer
  #             or token_type == token_type::signed_integer)
  #     - id: value_float
  #       type: f4
  #       if: >
  #         token_form == token_form::literal
  #         and token_type == token_type::floating_point
  #     - id: value_string
  #       type: smart_types::strl1
  #       if: >
  #         token_form == token_form::literal
  #         and (token_type == token_type::string
  #             or token_type == token_type::identifier)

  #     - type: u1
  #       valid: 0
  #       if: >
  #         token_form == token_form::literal
  #         and token_type != token_type::identifier





  lad_cell:
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









  fbd_cell:
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
      # - type: smart_types::null1
      - type: u1
        valid:
          any-of: [0, 1]

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
        type: u1
        # 0x00: string
        # 0x01: ...?
        # 0x02: identifier?
        # 0x00: number?

      - id: version
        type: u1
        valid:
          any-of: [3, 4]
        # seen in real projects:
        # 4 -> &MB_TaskTbl, &VB3040
        # 3 -> +2, 1, 0, 22, 4, 16#7000, 7

      - type: u1
        # 01 normal
        # 00 ...???

      - type: u4
        # valid: 0
        # sometimes 2

      - id: fixed1
        type: u1
        valid: 1

      - type: u4
        # usually: 0
        # 7: &VB100 (but only found in one place, with &VB0 this is 0)

      - id: token_form
        type: u1
        enum: token_form
        # 01: literal
        # 02: identifier















      # - id: token_flag  # TODO: rename
      #   type: u2
      #   enum: token_flag

      - id: token_type
        type: u1
        enum: token_type
        # if: offset > 0

      - id: mem_width
        type: u1
        enum: mem_width

      - id: arg_type
        type: u1
        enum: arg_type

        # 01=literal

        # arg_type=00=invalid, value_str
        # 00 02: #使能 -> local variable
        # 00 01: Always_On, 偏移量, 总值 -> global variable
        # 02 02: *#tmpPtr -> pointer dereference on local variable
        # 02 01: *指针 -> pointer dereference on global variable
        # 01 01: &MB_TaskTbl -> pointer from global variable

        # arg_type=01=literal_or_i_memory, value_str
        # 08 10: "hello"

        # arg_type=01=literal_or_i_memory, value_float
        # 07 08: 100.0, 0.0, 90.0, 1.0, 0.0

        # arg_type=01=literal_or_i_memory, value_int
        # 01 01: 0, 1 -> zero and one encoded as bit
        # 01 02: 10, 4 -> unsigned integer = byte
        # 01 04: 27648, 5530
        # 02 02: +100, +2
        # 02 01: +0 -> positive zero encoded as bit
        # 05 02: 2#1000100 -> binary literal
        # 04 01: 16#0 -> hexadecimal literal (1 bit)
        # 04 04: 16#7000 -> hexadecimal literal (2 bytes)

        ##################################################

        # 02=identifier

        # 20=m_memory, offset
        # 00 04: MW20, MW22
        # 00 01: M24.0, M24.1, M24.2

        # 10=v_memory, offset
        # 00 08: VD40
        # 00 04: VW0
        # 01 02: &VB100, &VB3040 -> pointer from byte memory address

        # 40=t_memory, offset
        # 00 01: T101


















      - id: before_string
        type: u4
        if: token_type == token_type::string
        # if: token_flag == token_flag::string2

      - id: value_str
        type: smart_types::strl1
        if: >
          token_form == token_form::literal
          and ((not arg_type == arg_type::literal_or_i_memory
          and (token_type == token_type::identifier
               or token_type == token_type::string
               or (arg_type == arg_type::invalid_or_hc_sm_scr_ac_l_pou_memory
                   and token_type == token_type::signed_integer
                   and (mem_width == mem_width::bit_or_some_text
                        or mem_width == mem_width::byte))
               or (token_type == token_type::unsigned_integer
                   and mem_width == mem_width::bit_or_some_text)))
               or (arg_type == arg_type::literal_or_i_memory
                   and token_type == token_type::string
                   and mem_width == mem_width::string))

        # if: >
        #   token_form == token_form::literal
        #   and (token_flag == token_flag::pointer_dereference
        #       or token_flag == token_flag::symbol
        #       or token_flag == token_flag::string2)

        # str might be identifier

      - id: value_int
        type: u4
        if: >
          token_form == token_form::literal
          and (token_type == token_type::unsigned_integer
               or token_type == token_type::binary
               or token_type == token_type::hexadecimal
               or (token_type == token_type::signed_integer
                   and mem_width != mem_width::bit_or_some_text)
               or ((token_type == token_type::signed_integer
                    or token_type == token_type::unsigned_integer)
                   and mem_width == mem_width::bit_or_some_text
                   and arg_type == arg_type::literal_or_i_memory))
          and not (arg_type == arg_type::invalid_or_hc_sm_scr_ac_l_pou_memory
                   and (token_type == token_type::unsigned_integer
                        or token_type == token_type::signed_integer)
                   and (mem_width == mem_width::bit_or_some_text
                        or mem_width == mem_width::byte))
        # if: >
        #   token_flag == token_flag::byte
        #   or token_flag == token_flag::word
        #   or token_flag == token_flag::int
        #   or token_flag == token_flag::dword
        #   or token_flag == token_flag::dint

      - type: u1
        valid: 0
        if: >
          token_form == token_form::literal
          and (token_type == token_type::unsigned_integer
               or token_type == token_type::binary
               or token_type == token_type::hexadecimal
               or (token_type == token_type::signed_integer
                   and mem_width != mem_width::bit_or_some_text)
               or ((token_type == token_type::signed_integer
                    or token_type == token_type::unsigned_integer)
                   and mem_width == mem_width::bit_or_some_text
                   and arg_type == arg_type::literal_or_i_memory))
          and not (arg_type == arg_type::invalid_or_hc_sm_scr_ac_l_pou_memory
                   and (token_type == token_type::unsigned_integer
                        or token_type == token_type::signed_integer)
                   and (mem_width == mem_width::bit_or_some_text
                        or mem_width == mem_width::byte))
        # ^ above condition copied from value_int

        # token_form == token_form::literal
        # and (token_type == token_type::unsigned_integer
        #     or token_type == token_type::signed_integer)
        # and not (token_type == token_type::signed_integer
        #         and mem_width == mem_width::bit_or_some_text)

        # if: >
        #   token_form == token_form::literal
        #   and (token_flag == token_flag::byte
        #       or token_flag == token_flag::word
        #       or token_flag == token_flag::int
        #       or token_flag == token_flag::dword
        #       or token_flag == token_flag::dint)

      - id: value_float
        type: f4
        if: token_type == token_type::floating_point
        # if: token_flag == token_flag::float

      - type: u1
        valid: 0
        if: token_type == token_type::floating_point
        # if: token_flag == token_flag::float

      - type: u1
        if: token_form == token_form::identifier
        # usually 0, but 4 when SCR bit

      - type: smart_types::nulls(2)
        if: token_form == token_form::identifier

      - id: offset
        type: u4
        if: >
          token_form == token_form::identifier
        # and token_type != token_type::unsigned_integer
        # and token_type != token_type::signed_integer

        # if: >
        #   token_form == token_form::identifier
        #   and token_flag == token_flag::symbol

      - id: fixed1_n2
        type: u2
        valid: 1
        if: >
          token_form == token_form::identifier
          and version == 4



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
        # usually found in imported POU
        # looks like SHA1, because length is always 20 = 160 bits
        # seems related to password, with password "1234", the hash is:
        # 27 09 c5 59 cb 56 49 5f 53 2f ce 04 1e 06 7b 9d 4e 10 b5 7e 6c
        # NOT related to: (confirmed)
        # - salt for sha512 above
        # - project name
        # - library name
        # - POU name
        # - timestamp
        # - dependencies
      - id: len2
        type: u4
      - id: encrypted_network_data
        size: len2
      # - type: smart_types::nulls(3)
      - type: u1
        valid: 0
      - type: u1
        valid:
          any-of: [0, 1, 2, 4]
      - type: u1
        valid:
          any-of: [0, 2]
        # usually 0
        # 2 seen in MBUSM1 and MBUS_MSG migrated from V2 to V3

  protection_v2:
    seq:
      - id: salt
        type: u2
      # - type: smart_types::nulls(20)
      - size: 20
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

  # TODO: rename
  network_type:
    0x0101: fbd
    0x0102: lad
    0x0106: stl

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
    0x03eb: function_block

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




  token_form:
    0x01: literal
    0x02: identifier

  token_type:
    0x00: identifier
    0x01: unsigned_integer
    0x02: signed_integer
    0x04: hexadecimal  # -> 16#abcd (just a guess for now, TODO: confirm)
    0x05: binary  # --> 2#010101010101
    0x07: floating_point
    0x08: string

  mem_width:
    0x01: bit_or_some_text
    0x02: byte
    0x04: word
    0x08: dword
    0x10: string

  arg_type:
    0x00: invalid_or_hc_sm_scr_ac_l_pou_memory
    0x01: literal_or_i_memory
    0x02: q_memory
    0x04: ai_memory
    0x08: aq_memory
    0x10: v_memory
    0x20: m_memory
    0x40: t_memory
    0x80: c_memory

  var_class:
    # 0x0000: not_local_variable
    # regular/other memory maybe?
    0x0001: hc_memory
    0x0002: sm_memory
    0x0004: s_memory
    0x0010: ac_memory
    0x0020: l_memory
    0x8000: pou

  # it looks like token_type and mem_width are not independent of each other
  # if token_type is 2 and mem_width is 2, then the arg is an integer value
  # if token_type is 2 and mem_width is 1, then the arg is a symbol pointer dereference

  token_flag:
    0x0100: symbol
    0x0102: pointer_dereference
    # 0x0108: str
    0x0201: byte
    0x0401: word
    0x0200: b_memory_address
    0x0400: w_memory_address
    0x0800: d_memory_address
    0x0402: int
    0x0801: dword
    0x0802: dint
    0x0807: float
    0x1008: string2












  # opcodes for the same instruction in STL and LAD are different
  # for example:
  # - STL -- ADD_R is 0x02c6
  # - LAD -- ADD_R is 0x014a
  stl_opcode:
    0x01fe: ld # NO contact
    0x0214: eq # = / output
    0x03e9: call
    0x03eb: fbcall
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
    0x0258: ldw_gt
    0x0238: get
    0x0239: put
    0x0230: xmt
    0x0231: rcv
    0x0236: gip
    0x0237: sip
    0x0234: gpa
    0x0235: spa



































