meta:
  id: pou
  endian: le
  imports:
    - smart_types


seq:
  # - size: 0x076b

  - id: version
    type: u1

  - id: pou_id
    type: u4
    enum: pou_type

  - id: index
    type: u2

  - type: u4
    valid: 1

  - type: smart_types::nulls(16)

  - id: editor_open
    type: u4
    enum: editor_open
    if: version > 7

  - id: block_version
    type: u2
    # 83 00: R03.01.00.00
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
    valid: 100

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

      - type: u2
        valid: 0x0102

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
        # if: block_version == 2

      - type: u4
        valid: 0

      - type: u1
        valid: 2

      - id: bookmark
        type: u4
        enum: bookmark_nobookmark

      - type: u4
        valid: 0

      - type: u1
        valid: 1

      - id: element_count
        type: u2

      - id: element
        type: element
        repeat: expr
        repeat-expr: element_count

  element:
    seq:
      - type: smart_types::null1

      - id: row
        type: u1

      - id: col
        type: u1

      - type: u2
        valid: 0x0103

      - id: element_type
        type: u2

      - type: u1
        # usually 0, sometimes but rarely 1

      - id: element_subtype
        type: u1

      - id: vertical_lines_right_side
        type: u1
        # this is a bit field

      - id: flags
        type: u2

      - id: label_line_count
        type: u1

      - id: label_l_r
        type: label_l_r
        repeat: expr
        repeat-expr: label_line_count

      - type: u2
        valid: 0x0101

      - id: param_count
        type: u2

      - id: param
        type: param_array
        repeat: expr
        repeat-expr: param_count

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

  param_array:
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
        # 0x0301: ...?
        # 0x0302: string
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

      - id: value_type5
        type: u1
        # 01: literal
        # 02: memory address

      - id: value_type2
        type: u1
        # 00: string
        # 01: whole number
        # 02: negative number?
        # 07: floating point

      - id: value_type3
        type: u1
        # 01: 1 bit, or string
        # 02: 16 bit? but sometimes 32-bit
        # 08: 32 bit

      - id: value_type4
        type: u1
        # 00: string
        # 01: number
        # 10: memory address Vx

      - id: value_str
        type: smart_types::strl1
        if: value_type2 == 0 and value_type5 == 1

      - id: value_int
        type: u4
        if: value_type2 == 1 or value_type2 == 2

      - type: u1
        valid: 0
        if: (value_type2 == 1 or value_type2 == 2) and value_type5 != 2

      - id: value_float
        type: f4
        if: value_type2 == 7

      - type: u1
        valid: 0
        if: value_type2 == 7

      - type: smart_types::nulls(3)
        if: value_type5 == 2

      - type: u4
        if: value_type2 != 1 and value_type5 == 2






  element_value:
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

      - id: data_type
        type: u2
        if: status_flags != 3

      - id: class_type
        type: u1
        if: status_flags != 3

      - type: u2
        valid: 0

      - id: offset
        type: u4
        if: status_flags != 3

      - type: u4
        valid: 0
        if: status_flags != 3

      - id: type_flags
        type: u4

      - type: u1
        valid: 0

      - id: comment
        type: smart_types::strl

      - type: u1
        valid: 2

      - id: direction
        type: u1

      - id: bitfield
        type: u2

      - id: extra
        type: u2

      - id: size_code
        type: u1

      - id: state
        type: u1

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
      - id: hash2
        size: len2
      - type: smart_types::nulls(3)

  protection_v2:
    seq:
      - size: 42
      - size: 44
      - type: smart_types::nulls(3)

  protection_v1:
    seq:
      - size: 22
      - type: smart_types::nulls(3)


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

















