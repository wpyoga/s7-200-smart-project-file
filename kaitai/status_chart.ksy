meta:
  id: status_chart
  endian: le
  imports:
    - smart_types


seq:
  # - size: 0x77cd
  # - size: 0x81c01
  # - size: 0x8f9f
  # - size: 0x8fc3
  # - size: 0x81c01

  - id: version
    type: u1
    valid:
      any-of: [3]
  - id: marker_1
    type: u4
    valid: 1
  - id: status_chart_count
    type: u2
  - id: block_version
    type: u1
    valid:
      any-of: [7, 8]
  - id: marker_4000
    type: u2
    valid: 4000
  - type: smart_types::nulls(2)
  - id: status_charts
    type: status_chart1
    repeat: expr
    repeat-expr: status_chart_count


types:
  status_chart1:
    seq:
      - id: index
        type: u2
      - id: version
        type: u2
        valid:
          any-of: [1]
      - id: null_bytes
        type:
          switch-on: _parent.block_version
          cases:
            7: smart_types::nulls(18)
            8: smart_types::nulls(22)
      - id: marker_2
        type: u2
        valid: 2
      - id: name
        type: smart_types::strl
      - type: smart_types::nulls(8)
      - id: entry_count
        type: u2
      - id: entry
        type: entry
        repeat: expr
        repeat-expr: entry_count
      - id: trailer
        size: 5
        # seems to be uninitialized memory

  entry:
    seq:
      - id: index
        type: u2
      - id: status_1a
        type: u1
        valid: 1
      - id: status_1b
        type: u1
        valid:
          any-of: [2, 1]
        # 2: identifier (default) meaning empty or invalid is also 2
        # 1: memory address
      - id: marker
        type: u2
        valid: 0x0103
      - id: type_1
        type: u1
      - id: type_2
        type: u1
      - id: null_2
        type: u2
        valid: 0
      - id: marker_1
        type: u1
        valid: 1
      - id: null_4
        type: u4
        valid: 0
      - id: flag_1
        type: u1
        valid:
          any-of: [1, 2]
          # 1: hello, , var_only (flag_5 not present, null afterwards not present, offset not present)
          # 2: VB, MW, SMD, T
          # -> identifier, or memory address
      - id: flag_2
        type: u1
        valid:
          any-of: [0, 1, 2, 3]
        # 0: hello, var_only -> incomplete symbol, q8.8 -> invalid memory address
        # 1: &VB1
        # 2: *VD2
        # 3: empty address
        # -> describes the address column
      - id: flag_3
        type: u1
        valid:
          any-of: [0, 1, 2, 4, 8]
        # 8: SMD80 -> D
        # 4: MW -> W
        # 2: VB -> B
        # 1: hello, , var_only, S1.2 -> bit, T32, T36
        # 0: empty
        # -> memory width

      - id: memory_area
        type: u2
        valid:
          any-of: [1, 2, 4, 8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x200, 0x400, 0x1000, 0x2000]
        if: flag_1 == 2  # memory address
        #   memory area
        #      1 = 01 00: I
        #      2 = 02 00: Q
        #      4 = 04 00: AIW
        #      8 = 08 00: AQW
        #   0x10 = 10 00: V
        #   0x20 = 20 00: M
        #   0x40 = 40 00: T
        #   0x80 = 80 00: C
        #  0x100 = 00 01: HC
        #  0x200 = 00 02: SM
        #  0x400 = 00 04: S
        # 0x1000 = 00 10: AC
        # 0x2000 = 00 20: L

      - type: smart_types::null1

      - id: address_or_name
        type: smart_types::strl1

      - id: address_offset
        type: u4
        if: flag_1 == 2

      - id: format
        type: u1
        enum: format

      - id: new_value_size
        type: u1

      - id: new_value
        size: new_value_size

      # new_value: must use some flags to determine data type,
      #            then make a value instance

      # - id: new_value_integer
      #   type: u4
      #   if: >
      #     (format == format::signed
      #       or format == format::unsigned
      #       or format == format::hexadecimal
      #       or format == format::binary)
      #     and new_value_size == 4

      # - id: new_value_floating_point
      #   type: u4
      #   if: >
      #     format == format::floating_point
      #     and new_value_size == 4

      # - id: new_value_ascii
      #   type: u4
      #   if: >
      #     format == format::ascii
      #     and new_value_size > 0

      # - id: new_value_string
      #   type: str
      #   encoding: ascii
      #   size: new_value_size
      #   if: >
      #     format == format::string
      #     and new_value_size > 0

      - id: marker_2a
        type: u1
        valid: 1

      # - id: marker_2b
      #   type: u2
      #   # valid:
      #   #   any-of: [0x0201, 0x0202, 0x0205, 0x4009, 0x0401, 0x0807, 0, 0x0101]
      #   # 0x4009 -> usually, empty, InWd_Val (float), MB_Idx (Signed)
      #   # 0x0807 -> InWd_4Wd (float)
      #   # 0x0000 -> empty (only 1 seen)
      #   # 0x0201 -> MB_Timeout (Signed)
      #   # 0x0101 -> Ch1_Blw_Mode
      #   # 0x0202 -> TV12
      #   # -> looks like it's unused or unitialized, at least some of the time

      # so far, this doesn't seem to be useful
      # might just be some leftover structure from previous versions
      # there is a curious case though: if flag_4 = 6 or flag_5 = 8 then can be compared
      - id: flag_4
        type: u1
      - id: flag_5
        type: u1

      - id: marker_2c
        type: u1
        valid: 1

      - id: new_value_shadow
        size: new_value_size
        if: >
          format == format::ascii
          or format == format::string

      - id: new_value_shadow_int
        size: 4
        valid:
          expr: >
            new_value_size == 0
            or (flag_4 != 6 or flag_5 != 8)
            or _ == new_value
        # TODO: not sure if we should check validity, or just accept the given value
        if: >
          new_value_size == 0
          or (format == format::signed
              or format == format::unsigned
              or format == format::hexadecimal
              or format == format::binary
              or format == format::floating_point
              or format == format::bit)

      # new_value_*_check: must use some flags to determine data type,
      #                    then make a value instance

      # - id: new_value_check
      #   size: new_value_size
      #   valid: new_value
      #   if: >
      #     not (format == format::ascii
      #           or format == format::string)

      # - id: new_value_integer_check
      #   type: u4
      #   valid: new_value_integer
      #   if: >
      #     (format == format::signed
      #       or format == format::unsigned
      #       or format == format::hexadecimal
      #       or format == format::binary)
      #     and new_value_size == 4

      # - id: new_value_floating_point_check
      #   type: u4
      #   valid: new_value_floating_point
      #   if: >
      #     format == format::floating_point
      #     and new_value_size == 4

      # - type: u4
      #   if: >
      #     format == format::ascii
      #     or format == format::string
      #     or new_value_size == 0

      - id: new_value_invalid_content
        type: smart_types::strl1

      - type: u4
        repeat: expr
        repeat-expr: 12
        # this is an unknown block of 48 bytes long
        # usually starts with 0x80, but not always

      - type: u4
        valid: 0x4b






enums:
  format:
    0: signed
    1: unsigned
    2: hexadecimal
    3: binary
    4: floating_point
    5: ascii
    6: string
    8: bit

























