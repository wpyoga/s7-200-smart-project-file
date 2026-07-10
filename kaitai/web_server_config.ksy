meta:
  id: web_server_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0xb95d
  # - size: 0x4231d
  # - size: 0xb95b

  - id: marker
    type: u1

  - id: activate
    type: u4

  - id: fixed_ip_address_and_station_name
    type: u4

  - id: ip_address
    type: smart_types::ipv4_addr

  - id: subnet_mask
    type: smart_types::ipv4_addr

  - id: default_gateway
    type: smart_types::ipv4_addr

  - id: station_name
    type: smart_types::strl

  - id: marker_2
    type: u1

  - id: num_watch_table
    type: u4

  - id: watch_table
    type: watch_table
    repeat: expr
    repeat-expr: num_watch_table

  - id: marker_3
    type: u1

  - id: num_user
    type: u4

  - id: user
    type: user
    repeat: expr
    repeat-expr: num_user

  - id: precompiled_web_server_config
    type: precompiled_web_server_config


types:
  watch_table:
    seq:
      - id: index
        type: u1

      - id: name
        type: smart_types::strl

      - id: comment
        type: smart_types::strl

      - id: num_tag
        type: u4

      - id: tag
        type: tag
        repeat: expr
        repeat-expr: num_tag

  tag:
    seq:
      - id: marker
        type: u1

      - id: name
        type: smart_types::strl

      - id: address
        type: smart_types::strl

      - id: format
        type: u4
        # 00 00 00 00: signed
        # 01 00 00 00: unsigned
        # 02 00 00 00: hexadecimal
        # 03 00 00 00: binary
        # 04 00 00 00: floating point
        # 05 00 00 00: ascii
        # 08 00 00 00: bit

      - id: marker_2
        type: u4
        valid: 1

      - id: address_type
        type: u4
        # 1: bit
        # 2: byte
        # 4: word
        # 8: dword

      - id: memory_area
        type: u4
        # 01 00 00 00: I
        # 02 00 00 00: Q
        # 04 00 00 00: AI
        # 08 00 00 00: AQ
        # 10 00 00 00: V
        # 20 00 00 00: M
        # 40 00 00 00: T
        # 80 00 00 00: C
        # 00 01 00 00: HC
        # 00 02 00 00: SM
      - id: offset
        type: u4
        # bit or byte offset depending on address type

  user:
    seq:
      - id: marker
        type: u1

      - id: name
        type: smart_types::strl

      - id: password_hash
        size: 64
        # SHA512 of user password without any salt

      - id: permissions
        size: 8
        # this is a bit field
        #  a  b  c  d  e  f  g  h
        # 00 00 00 40 00 00 00 00: minimal (no permissions granted)
        #             with 3rd party api and user defined web page
        # 00 00 00 00 00 00 00 00: also minimal (no permissions)
        #          without 3rd party api and user defined web page
        # 01 00 00 00 00 00 00 00: read module information
        # 00 00 01 15 00 00 00 00: status chart read only
        #                          watch table 1 read only
        #                          watch table 2 read only
        #                          watch table 3 read only
        # 01 01 02 2a 02 01 02 02: administrative
        #                          read module information
        #                          set clock
        #                          status chart read and write
        #                          watch table 1 read and write
        #                          watch table 2 read and write
        #                          watch table 3 read and write
        #                          read event log
        #                          data log upload
        #                          flash led
        #                          run/stop cpu
        # "configure as administator" in the UI is only UI
        # it does not have any associated data
        # in fact, selecting all the relevant permissions will
        #   automatically select "configure as administrator"
        # a.0: read module information
        # b.0: read event log
        # c.0: status chart read only
        # c.1: status chart read and write
        # d.0: watch table 1 read only
        # d.1: watch table 1 read and write
        # d.2: watch table 2 read only
        # d.3: watch table 2 read and write
        # d.4: watch table 3 read only
        # d.5: watch table 3 read and write
        # d.6: user defined web page??
        # d.7: third party api read and write
        # f.0: data log upload
        # g.1: run/stop cpu
        # h.1: flash led



  precompiled_web_server_config:
    meta:
      endian: be
    seq:
      - id: marker
        type: u1
        valid: 1

      - id: num_precompiled_watch_table
        type: u4le

      - id: watch_table
        type: precompiled_watch_table
        repeat: expr
        repeat-expr: num_precompiled_watch_table

      - type: u1
      - id: num_precompiled_user
        type: u4le

      - id: user
        type: precompiled_user
        repeat: expr
        repeat-expr: num_precompiled_user

  precompiled_watch_table:
    meta:
      endian: be
    seq:
      - id: marker
        type: u1
        valid: 1

      - id: name
        type: smart_types::strn(32)

      - id: num_precompiled_tag
        type: u4le

      - id: tag
        type: precompiled_tag
        repeat: expr
        repeat-expr: num_precompiled_tag

  precompiled_tag:
    meta:
      endian: be
    seq:
      - id: marker
        type: u1

      - id: name
        type: smart_types::strn(32)

      - id: double_bit_number
        type: u1
        # f4 = xx.2
        # f6 = xx.3
        # fc = xx.6
        # fe = xx.7

      - id: address_type
        type: u1
        # 80: V
        # 00: I
        # 10: Q
        # 20: M

      - id: byte_offset
        type: u2

      - id: format
        type: u4

      - id: num_bits
        type: u2
        #  1: bit
        #  8: byte
        # 16: word
        # 32: dword

  precompiled_user:
    meta:
      endian: be
    seq:
      - id: marker
        type: u1
        valid: 1

      - id: permissions
        size: 8

      - id: name
        type: smart_types::strn(32)

      - id: password_hash
        size: 64


































