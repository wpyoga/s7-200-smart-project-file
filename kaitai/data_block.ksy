meta:
  id: data_block
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x88db8
  # - size: 0x0be5
  # - size: 0x0768
  # - size: 0x0af4
  # - size: 0x0a70
  # - size: 0x0a7c
  # - size: 0x2e525
  # - size: 0x54006
  # - size: 0xd19a
  # - size: 0xb62c
  # - size: 0xb173
  # - size: 0x641b

  - id: marker
    type: u1
    valid: 2

  - id: num_pages
    type: u2

  - id: data_page
    type: data_page
    repeat: expr
    repeat-expr: num_pages


types:
  data_page:
    seq:
      - id: version
        type: u1
        # 08: R02.04.00.00 & R03.01.00.00
        # 07: R01.00.00.00 & MWP

      - id: marker
        type: u2
        valid: 0x1388

      - type: smart_types::nulls(2)

      - id: index
        type: u2

      - type: u2
        # valid: 0x0001
        # sometimes 0x0040

      - id: hash_maybe
        type:
          switch-on: version
          cases:
            8: smart_types::nulls(22)
            7: smart_types::nulls(18)

      - id: version_again
        type: u2

      - id: name
        type: smart_types::strl

      - type: smart_types::nulls(4)

      - id: author
        type: smart_types::strl

      - id: protection
        type:
          switch-on: version
          cases:
            8: protection_v2
            7: protection_v1
        if: version_again > 2

      - type: smart_types::nulls(2)
        if: version_again == 2
        # TODO: figure out the exact mechanism here
        # was version_again some kind of sub-version?
        # obviously we cannot rely on version == 7

      - id: num_rows
        type: u2

      - id: rows
        type: data_page_row
        repeat: expr
        repeat-expr: num_rows

      - id: comment_version
        type: u1

      - id: num_rows_comment
        type: u2

      - id: data_page_comment
        type: data_page_comment(comment_version)
        repeat: expr
        repeat-expr: num_rows_comment

      - id: aux_len
        type: u2

      - id: unknown_aux
        size: aux_len


  data_page_row:
    seq:
      - id: index
        type: u2

      - type: u1
        valid: 2

      - id: assignment_type
        type: u1
        # valid: [0, 1, 2]
        # 0: empty
        # 1: normal assignment
        # 2: assignment for undefined memory type

      # sometimes when row is invalid, this value is garbage
      # otherwise it is usually null
      - type: u4

      - type: u1
        valid: 1

      # sometimes when row is empty, this value is garbage
      # otherwise it is usually null
      - type: u4

      - type: smart_types::nulls(4)

      - type: u2
        valid: 0x0101

      - id: num_elem
        type: u2

      - id: elem
        type: elem
        repeat: expr
        repeat-expr: num_elem






  elem:
    seq:
      - id: index
        type: u2

      - id: marker
        type: u1
        # valid: 1
        # 01: valid
        # 02: invalid

      - id: marker2
        type: u2
        valid: 0x0103

      - id: status
        type: u4
        # 00: valid
        # 01: invalid

      - id: marker3
        type: u1
        valid: 1

      - id: str_pos
        type: u4
        # string offset from start of line

      - id: identifier_type
        type: u2
        # 01 00: / world
        # 01 01: 44 251 250 253 254 1023 65535 99999
        # 01 04: 16#FF 16#FFFF
        # 01 05: 2#11
        # 01 06: 'abcdefghijkl' 'abcd'
        # 01 08: "abcd"
        # 01 07: 3.14
        # 02 00: VB333 VW2222 VD2 V1 VB254 VW254 VD254

      - id: identifier_subtype
        type: u2
        # should mean data type or size
        # 01 00: / world
        # 02 01: 16#FF 2#11 44 251 250 253 254
        # 04 01: 16#FFFF 1023 65535
        # 08 01: 3.14 99999
        # 10 01: 'abcdefghijkl' 'abcd' "abcd"
        # 02 10: VB333 VB254
        # 04 10: VW2222 VW254
        # 08 10: VD2 VD254
        # 40 10: V1

      - id: element
        type:
          switch-on: identifier_type
          cases:
            0x0001: smart_types::strl1
            0x0002: elem_offset_type(identifier_subtype)
            0x0101: elem_addr_type(identifier_subtype)
            0x0201: elem_constant_type(identifier_subtype)
            0x0401: elem_constant_type(identifier_subtype)  # hex
            0x0501: elem_constant_type(identifier_subtype)
            0x0601: elem_ascii_constant_type(identifier_subtype)  # ascii
            0x0701: elem_constant_type(identifier_subtype)
            0x0801: elem_ascii_constant_type(identifier_subtype)


  elem_offset_type:
    params:
      - id: subtype
        type: u2
    seq:
      - type: smart_types::nulls(3)

      - id: offset
        type: u4

  elem_ascii_constant_type:
    params:
      - id: subtype
        type: u2
    seq:
      - type: smart_types::nulls(4)

      - id: ascii_constant
        type: smart_types::strl1

  elem_constant_type:
    params:
      - id: subtype
        type: u2
    seq:
      - id: value
        type: u4

      - type: smart_types::null1




  elem_addr_type:
    params:
      - id: subtype
        type: u2
    seq:
      # - type: smart_types::nulls(3)

      - id: mem_address
        type: u4

      - type: smart_types::null1





  protection_v2:
    seq:
      - id: salt
        type: u2
      - type: smart_types::nulls(20)
      - id: sha512
        size: 64
        # this is sha512 of password+salt

  protection_v1:
    seq:
      - type: smart_types::nulls(22)





  # MAYBE: rename to data_page_comment
  data_page_comment:
    params:
      - id: version
        type: u1
    seq:
      - type: smart_types::nulls(4)
        if: version == 0x02

      - id: index
        type: u2

      - id: aux_type
        type: u2
        if: index != 0xffff
        # 02 01: row contains only comment starting at column 0
        # 02 07: row does not contain comment, or empty row
        # 02 02: row contains comment at column 35


      - type: u2
        if: index != 0xffff
        # MAYBE: starting column of comment
        # OR: length of valid data
        #  0: row contains only comment at column 0
        #  3: row contains only comment at column 35
        #  7: row invalid, invalid element at column 7
        # 10: valid assignment row without comment, row length 10
        # 11: valid assignment row without comment, row length 11
        # 20: valid assignment row without comment, row length 20
        # 35: valid assignment row with comment (at column 35)
        # 45: valid assignment row without comment, row length 45

      - type: u2
        if: index != 0xffff

      - type: smart_types::null1
        if: index != 0xffff

      - id: comment
        type: smart_types::strl
        if: index != 0xffff

















































