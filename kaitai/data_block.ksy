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

      - id: num_rows
        type: u2

      - id: rows
        type: data_page_row
        repeat: expr
        repeat-expr: num_rows

      - id: aux_version
        type: u1

      - id: num_rows_aux
        type: u2

      - id: data_page_aux
        type: data_page_aux(aux_version)
        repeat: expr
        repeat-expr: num_rows_aux

      - id: aux2_len
        type: u2

      - id: unknown_aux2
        size: aux2_len


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

      - type: smart_types::nulls(4)

      - type: u1
        valid: 1

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

      - id: identifier_subtype
        type: u2
        # should mean data type or size

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








  data_page_aux:
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

      - type: u2

      - type: u2

      - type: smart_types::null1

      - id: comment
        type: smart_types::strl

















































