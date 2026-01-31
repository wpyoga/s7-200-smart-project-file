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
        # before 0x12, there is no encoded version

  # might be version, not sure
  - id: magic
    type: u1
    valid: 3

  - id: modbus_station_port0
    type: u4

  - id: last_connected_ip
    type: smart_types::ipv4_addr

  - type: smart_types::null1

  # seems to be: software version that originally created this project
  - id: software_version
    type: smart_types::strl

  - type: smart_types::null1

  - id: project_name
    type: smart_types::strl

  - type: smart_types::null1

  - id: view_mode
    type: u4
    enum: view_mode

  - id: printer_information
    type: printer_information(editor_version)


types:

  encoded_version_8:
    seq:
      - size: 8

  encoded_version_4:
    seq:
      - size: 4

  printer_information:
    params:
      - id: editor_version
        type: u1
    instances:
      paper_width_inch:
        value: paper_width_twip / 1440.0
      paper_height_inch:
        value: paper_height_twip / 1440.0
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
      # also see below, after the print options
      - id: marker
        type: u4
        # the marker is either null, or 01 04 05 40
        # note: 0x0401 = 1025, 0x4005: 16389
      - type: smart_types::unknown(112)
        # if marker is not null, this is always the value:
        # starts with 32 bytes:
        # 9c 00 62 04 0f ff 00 1e 01 00 01 00 ea 0a 6f 08
        # 64 00 01 00 07 00 2c 01 02 00 01 00 2c 01 03 00
        ### the values above do make sense if read as u2 each
        ### but we don't currently know what they mean
        ###   156  1122 65295  7680 1 1  2794  2159
        ###   100     1     7   300 2 1  300      3
        # then 56 null bytes
        # then 6x u4 values: 1, 3, 1, 1, 0, 0
      - size: 8
        if: >
          marker != 0x40050401
          and editor_version >= 0x12

      - id: margin_left
        type: u4
      - id: margin_top
        type: u4
      - id: margin_right
        type: u4
      - id: margin_bottom
        type: u4

      # a twip is one-twentieth of a point
      # a point is 1/72 of an inch
      - id: paper_width_twip
        type: u4
      - id: paper_height_twip
        type: u4
      - type: u2
        valid: 0

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
      - type: u2
        valid: 0
      - type: smart_types::nulls(8)
        if: >
          marker == 0x40050401
          and editor_version >= 0x12



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
