meta:
  id: preamble
  endian: le
  imports:
    - smart_types

seq:
  - id: editor_version
    type: u1

  # Encoded version (usually 8 bytes, sometimes 4)
  - id: encoded_version
    type:
      switch-on: editor_version
      cases:
        '0x1c': encoded_version_8
        '0x1b': encoded_version_8
        '0x1a': encoded_version_8
        '0x18': encoded_version_8
        '0x12': encoded_version_4

  # Constant separator (usually 0x03)
  - id: magic
    type: u1

  - id: modbus_station_port0
    type: u4

  - id: last_connected_ip
    type: smart_types::ipv4_addr

  - type: smart_types::null1

  - id: software_version
    type: smart_types::strl

  - type: smart_types::null1

  - id: project_filename
    type: smart_types::strl

  - type: smart_types::null1

  - id: view_mode
    type: u4
    enum: view_mode

  - id: printer_information
    type: printer_information


types:

  encoded_version_8:
    seq:
      - size: 8

  encoded_version_4:
    seq:
      - size: 4

  printer_information:
    seq:
      - type: u1
        valid: 1
      - id: last_connected_printer
        type: str
        size: 32
        encoding: ASCII

      # there is something really funny going on here
      # if the marker+unkown block is not null, the
      # following null block (8 bytes) is not present
      - id: marker
        type: u4
      - type: smart_types::unknown(112)
      - size: 8
        if: marker != 0x40050401

      - id: margin_left
        type: u4
      - id: margin_top
        type: u4
      - id: margin_right
        type: u4
      - id: margin_bottom
        type: u4
      - size: 10
      - id: justify_header
        type: u2
      - id: justify_footer
        type: u2
      - id: print_header
        size: 256
        type: strz
        encoding: ASCII
      - id: print_footer
        size: 256
        type: strz
        encoding: ASCII
      - type: smart_types::nulls(512)
      - type: smart_types::nulls(2)
      - id: lad_print_options
        type: print_options
      - id: fbd_print_options
        type: print_options
      - id: stl_print_options
        type: print_options
      - id: sym_print_options
        type: print_options
      - id: cht_print_options
        type: print_options
      - id: db_print_options
        type: print_options
      - type:
          switch-on: _root.editor_version
          cases:
            0x1c: smart_types::nulls(2)
            0x1b: smart_types::nulls(2)
            0x1a: smart_types::nulls(2)
            0x18: smart_types::nulls(2)
            0x12: smart_types::nulls(10)



  print_options:
    seq:
      - id: marker
        type: u1
      - id: col
        type: u2
      - id: props
        type: u2
      - id: vars
        type: u2
      - id: comments
        type: u2
      - id: syms
        type: u2
      - id: lines
        type: u2


enums:
  view_mode:
    0: lad
    1: stl
    2: fbd
