meta:
  id: profinet_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x5eb67
  # - size: 0x5ecae
  # - size: 0xba6ba
  # - size: 0x8e089
  # - size: 0xba798

  - id: marker
    type: u1
    valid: 1

  - id: marker_2
    type: u1
    valid: 1

  - id: start_up_time_ms
    type: u4

  - id: profinet_device_config
    type: u4
    # this is a bit field
    # 00 00 00 00: not configured
    # 02 00 00 00: controller
    # 04 00 00 00: i-device
    # 08 00 00 00: controller & i-device

  - type: u4

  - type: u1
    valid: 1

  - id: send_clock
    type: f4

  - id: station_name
    type: smart_types::strl

  - id: ip_address
    type: smart_types::ipv4_addr

  - id: subnet_mask
    type: smart_types::ipv4_addr

  - id: default_gateway
    type: smart_types::ipv4_addr

  - id: flag
    type: u4
    # 00 00 00 00: controller & i-device not configured
    # 02 00 00 00: maybe controller
    # 03 00 00 00: maybe i-device
    #              (also when device is both controller and i-device)
    # maybe this denotes the type of the following block
    # and controller & i-device config block can come in any order

  # - id: config_block_1
  #   type:
  #     switch-on: flag
  #     cases:
  #       2: controller_config_block
  #       3: idevice_config

  - id: controller_config_block
    type: controller_config_block
    if: profinet_device_config == 2 or profinet_device_config == 8

  - type: smart_types::null1
  # - type: u1

  - id: idevice_config
    type: idevice_config
    # if: profinet_device_config == 4 or profinet_device_config == 8

  - id: precompiled_profinet_block
    type: precompiled_profinet_block
    if: profinet_device_config > 0

  - type: smart_types::null1
    if: profinet_device_config == 0

  # TODO: figure out the actual logic
  - type: smart_types::null1
    if: profinet_device_config == 0

types:

  # looks like precompiled profinet config for the PLC
  # this block is big-endian, matching the PLC endianness
  # while other blocks are little-endian, matching PC endianness
  precompiled_profinet_block:
    meta:
      endian: be
    seq:
      # looks like some kind of header or preamble
      - size: 4

      # related to i-device config
      - id: block_len_a
        type: u4le
      - id: precompiled_config_a
        type: precompiled_config_a
        size: block_len_a



      - type: u1

      - id: profinet_device_config_sub
        type: u4le
        valid: _parent.profinet_device_config

      # also related to i-device config
      - id: block_len_b
        type: u4le
      - id: precompiled_config_b
        type: precompiled_config_b
        size: block_len_b

      # related to controller config
      - id: num_controller_config
        type: u4le
      - id: precompiled_controller_config
        type: precompiled_controller_config
        repeat: expr
        repeat-expr: num_controller_config
        # todo: find this info somewhere
        # this is the number of devices
        # configured under controller

  # precompiled_config_a:
  #   meta:
  #     endian: be
  #   seq:
  #     - size: 30

  #     - id: start_up_time_ms
  #       type: u4

  #     - id: marker_1
  #       type: u2
  #       # valid: 1

  #     - id: marker_2
  #       type: u2
  #       # valid: 0x1cd0

  #     - id: marker_0
  #       type: u2
  #       valid: 0

  #     - size: 14
  #     - id: marker
  #       type: u2
  #       valid: 0x0119

  # precompiled_config_b_old:
  #   meta:
  #     endian: be
  #   seq:
  #     - id: marker_2
  #       type: u2
  #       # valid: 0x1cd0

  #     - id: marker_0
  #       type: u2
  #       valid: 0

  #     - size: 14
  #     - id: marker
  #       type: u2
  #       # valid: 0x0119

  #     - size: 10

  #     - id: start_up_time_ms
  #       type: u4

  precompiled_config_a:
    meta:
      endian: be
    seq:
      - type: precompiled_marked_block
        repeat: eos

  precompiled_config_b:
    meta:
      endian: be
    seq:
      - type: precompiled_marked_block
        repeat: eos

  precompiled_marked_block:
    meta:
      endian: be
    seq:
      - id: block_len
        type: u1
      - id: marker
        type: u1
        valid:
          any-of: [0xd0, 0xd6, 0xd5, 0xd7, 0xd8]
      - size: block_len - 2
        if: block_len != 255
      # TODO: confirm this logic... seems wrong
      # block_len of 255 seems to denote an internal
      # structure containing its own block lengths
      - type: precompiled_marked_block_sub
        if: block_len == 255


  precompiled_marked_block_sub:
    meta:
      endian: be
    seq:
      - type: u4
      - type: u4

      - id: block_len
        type: u2
      - id: sub_block_2
        type: sub_block_2
        size: block_len
      # and this has yet another sub block
      # with internal marked length

  sub_block_2:
    meta:
      endian: be
    seq:
      - type: u1
      - type: u4
      - type: u4
      - type: u4
      - type: u1
        valid: 1

      - id: block_len
        type: u2
      - id: sub_block_3
        type: sub_block_3
        size: block_len

  sub_block_3:
    meta:
      endian: be
    seq:
      - size: 12
      - id: max_subslot
        type: u2
      - size: 28
      - type: precompiled_subslot
        size: 24
        repeat: eos

  # these are all i-device config
  precompiled_subslot:
    meta:
      endian: be
    seq:
      - id: subslot
        type: u2
        # 1000 ~ 1007: transfer area
        # 32768: DAP
        # 32769: Ethernet Port 1
      - type: u2
        valid: 0
      - id: type
        type: u1
        #  0: not idevice
        # 10: input
        # 20: output
      - type: u2
        valid:
          expr: 'type == 0 or _ == 0'
      - id: length
        type: u1
      - type: u1
        valid: 0
      - size: 6
      - id: length_copy
        type: u1
        # valid: length
        valid:
          expr: 'type == 0 or _ == length'
      - size: 8


  precompiled_controller_config:
    meta:
      endian: be
    seq:
      - type: u1
      - type: u2
      - id: block_len
        type: u2le
      - id: precompiled_sub_data
        type: precompiled_sub_data
        size: block_len
      - type: smart_types::nulls(2)

  precompiled_sub_data:
    meta:
      endian: be
    seq:
      - size: 42
      - id: ip_address
        type: smart_types::ipv4_addr
      - type: u2
      - id: cpu_device_name
        type: smart_types::strl_be
      - id: attr
        type: u2
      - size: 3
        if: attr == 0
      - size: 2
        if: attr == 1

      - id: cpu_submodule_device_name
        type: smart_types::strl_be
      - size: 399

      - id: subslot_1_a
        type: u2
      - id: pni_start_addr_bits_1
        type: u4
        # bits: divide by 8 to get the byte offset
      - id: pnq_start_addr_bits_1
        type: u4

      - id: subslot_2_a
        type: u2
      - id: pni_start_addr_bits_2
        type: u4
      - id: pnq_start_addr_bits_2
        type: u4

      - size: 18


      # TODO: figure out the structure
      # - type: smart_types::strl_be
      # - size: 9
      # - type: smart_types::strl_be
      # - id: subslot_1
      #   type: u2
      # - id: flag_1
      #   type: u2
      # - id: size_1
      #   type: u2
      # - type: smart_types::strl_be
      # - id: subslot_2
      #   type: u2
      # - id: flag_2
      #   type: u2
      # - id: size_2
      #   type: u2
      # comment out for now
      # - type: smart_types::strl_be
      # - size: 27
      # - id: plant_designation
      #   type: smart_types::strn(32)
      # - id: location_designation
      #   type: smart_types::strn(22)
      # - size: 26
      # - id: installation_date
      #   type: smart_types::strn(32)
      # - size: 10
      # - id: additional_information
      #   type: smart_types::strn(54)
      # - size: 16
      # - id: name_len
      #   type: u2
      # - type: u2
      # - id: dev_name
      #   size: name_len
      # - size: 18
      # - id: ip_address_2
      #   type: smart_types::ipv4_addr
      # - id: netmask
      #   type: smart_types::ipv4_addr
      # - id: ip_address_3
      #   type: smart_types::ipv4_addr
      # - size: 18



  controller_config_block:
    seq:
      - id: num_controller_device
        type: u1
      - id: controller_config
        type: controller_config
        repeat: expr
        repeat-expr: num_controller_device


  controller_config:
    seq:
      - id: maybe_index
        type: u4
      - type: u1
      - id: ip_address
        type: smart_types::ipv4_addr
      - id: update_time_ms
        type: f4
      - id: data_hold
        type: u4
      - type: u4
      - id: maybe_marker
        type: u1
      - id: device_number
        type: smart_types::strl
      - id: cpu_type_ver
        type: smart_types::strl
      - id: device_name
        type: smart_types::strl
      - id: device_name_copy
        type: smart_types::strl
      - id: comment
        type: smart_types::strl
      - type: smart_types::strl
      - id: art_nr
        type: smart_types::strl
      - type: smart_types::strl

      - id: num_param
        type: u4
      # - type: smart_types::strl
      #   repeat: expr
      #   repeat-expr: 10

      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
      - id: maybe_marker_2
        type: u1
      - type: smart_types::strl
      - type: smart_types::strl
      - id: maybe_marker_3
        type: u1
      - type: smart_types::strl
      - type: smart_types::strl
      - type: u1
      - type: u1
      - type: smart_types::strl
      - type: smart_types::strl
      - type: u1
      - type: u1
      - type: u1
      - type: smart_types::strl
      - type: u1
      - type: u1
      - type: u1
      - type: smart_types::strl
      - type: u1
      - type: u4
      - type: smart_types::strl
      - size: 7
      - type: u4
      - type: u1
      - type: smart_types::strl
      - type: u1
      - type: u1
      - type: u1
      - id: comment_1
        type: smart_types::strl
      - size: 9
      - type: smart_types::strl
      - type: smart_types::strl
      - type: u1
      - type: smart_types::strl
      - type: smart_types::strl
      - type: u1
      - type: u1
      - type: smart_types::strl
      - type: smart_types::strl
      - type: u1
      - type: u1
      - type: u1
      - type: smart_types::strl
      - type: u2
      - type: u4

      - type: ndict(1, 2)
      - type: u2

      - type: smart_types::strl
      - type: smart_types::strl
      - type: u2
      - type: smart_types::strl
      - type: u1
      - type: u1
      - type: u1
      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
      - type: u1
      - type: u1


      - type: ndict(1, 0)
      - size: 11
      - id: comment_2
        type: smart_types::strl
      - size: 9
      - type: smart_types::strl
      - type: smart_types::strl
      - type: u1
      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
      - size: 44

      - type: ndict(1, 0)
      - type: ndict(1, 4)
      - type: ndict(1, 1)

      - type: u1

      - type: nlist(1, 0)
      - type: ndict(1, 0)
      - type: ndict(1, 0)

      - type: u2

      # looks like a reverse dict u2 -> str
      - id: count_7a
        type: u1
      - type: u1
      - id: interface_subslot
        type: u2
      - id: interface_subslot_label
        type: smart_types::strl
      - type: u1
      - id: port1_subslot
        type: u2
      - id: port1_subslot_label
        type: smart_types::strl

      - type: u1
      - type: u2
      - type: u2

      - type: ndict(1, 0)

      - type: u1

      - type: ndict(1, 0)

      - type: u4
      - type: u4

      - type: u1

      - type: ndict(1, 0)
      - type: ndict(1, 0)
      - type: ndict(1, 1)
      - type: ndict(1, 2)

      - type: u1
      - type: u4
      - type: u4

      - type: ndict(1, 0)
      - type: ndict(1, 4)

      - type: u2

      - type: ndict(1, 0)
      - type: ndict(1, 2)
      - type: ndict(1, 4)

      - size: 3

      - type: ndict(1, 0)

      - size: 56

      - type: ndict(2, 0)

      - id: count_21
        type: u2
      - type: dict(count_21, 256)

      - id: count_22
        type: u2
      - type: dict(count_22, 256)

      - type: ndict(2, 1)
      - type: ndict(2, 0)
      - type: ndict(2, 2)
      - type: ndict(2, 2)

      - size: 32

      - type: ndict(2, 0)

      - size: 8

      - type: smart_types::strl
      - type: smart_types::strl

      - size: 5

      - type: ndict(1, 0)
      - type: ndict(1, 1)
      - type: ndict(1, 2)
      - type: ndict(1, 4)

      - size: 68

      - id: submodule_1_subslot
        type: submodule
      - id: submodule_2_subslot
        type: submodule
      - id: submodule_3_subslot
        type: submodule
      - id: submodule_4_subslot
        type: submodule
      - id: submodule_5_subslot
        type: submodule
      - id: submodule_6_subslot
        type: submodule
      - id: submodule_7_subslot
        type: submodule
      - id: submodule_8_subslot
        type: submodule

      - size: 36




  submodule:
    seq:
      - id: subslot
        type: u4
      - id: present
        type: u1
      - id: submodule_config
        type: submodule_config
        if: present == 1

  submodule_config:
    seq:
      - size: 5
      - id: subslot
        type: u4
        valid: _parent.subslot
      - size: 23

      - type: smart_types::strl
      - type: smart_types::strl
      - type: u1
      - type: smart_types::strl
      - type: smart_types::strl
      - size: 20
      - id: pni_start_addr_str
        type: smart_types::strl
      - size: 8
      - id: input_size_bytes
        type: u2

      # - id: pnq_start_addr_str
      #   type: smart_types::strl
      # - size: 8
      # - id: output_size_bytes
      #   type: u2
      - id: submodule_1_pnq_start_addr_str
        type: smart_types::strl
      - size: 8
        # TODO: refactor this logic
        if: submodule_1_pnq_start_addr_str.len > 0
      - id: submodule_1_output_size_bytes
        type: u2
        if: submodule_1_pnq_start_addr_str.len > 0

      - type: u2
        # TODO: refactor this logic
        if: submodule_1_pnq_start_addr_str.len > 0
      - type: u1

        # "OctetString"
      - type: smart_types::strl

      - id: count_25
        type: u2
      - type: u1
      - type: smart_types::strl
      - type: u2

      - id: count_26
        type: u2
      - type: u1
      - type: dict(count_26,4)

      - size: 8
      - size: 12
        # TODO: refactor this logic
        if: submodule_1_pnq_start_addr_str.len == 0

      - type: nlist(1,0)
      - type: u2
      - type: smart_types::strl
      - type: u2
      - type: ndict(1,4)
      - type: ndict(1,1)
      - type: u2
      - type: ndict(1,0)
      - type: ndict(1,0)
      - type: ndict(1,0)



  idevice_config:
    seq:
      - id: num_transfer_area
        type: u1

      - id: transfer_area
        type: transfer_area
        repeat: expr
        repeat-expr: num_transfer_area

      # - type: smart_types::nulls(5)
      - id: cpu_name
        type: smart_types::strl
        if: num_transfer_area > 0
      - id: cpu_description
        type: smart_types::strl
        if: num_transfer_area > 0
      - type: smart_types::strl
        if: num_transfer_area > 0

  transfer_area:
    seq:
      - id: marker
        type: u1
        valid: 0

      - id: subslot
        type: u4

      - id: length
        type: u4

      - id: name
        type: smart_types::strl

      - id: comment
        type: smart_types::strl

      - id: marker_2
        size: 3

      - id: type
        type: u4
        # 1: input
        # 2: output

      - id: offset
        type: u4

      # null is actually at the start of transfer area
      # - type: smart_types::null1


  nlist:
    params:
      - id: count_type
        type: u4
      - id: entry_type
        type: u4
    seq:
      - id: count
        type:
          switch-on: count_type
          cases:
            1: u1
            2: u2
            4: u4
      - id: entries
        type:
          switch-on: entry_type
          cases:
            0: smart_types::strl
            1: u1
            2: u2
            4: u4
        repeat: expr
        repeat-expr: count

  list:
    params:
      - id: len
        type: u4
      - id: entry_type
        type: u4
    seq:
      - id: entries
        type:
          switch-on: entry_type
          cases:
            0: smart_types::strl
            1: u1
            2: u2
            4: u4
        repeat: expr
        repeat-expr: len

  ndict0:
    params:
      - id: count_type
        type: u4
      - id: num_pre_null
        type: u4
      - id: entry_type
        type: u4
    seq:
      - id: count
        type:
          switch-on: count_type
          cases:
            1: u1
            2: u2
            4: u4
      - type: smart_types::nulls(num_pre_null)
      - id: entries
        type:
          switch-on: entry_type
          cases:
            0: entry_str_str
            1: entry_str_u1
            2: entry_str_u2
            4: entry_str_u4
            256: entry_u2_str
        repeat: expr
        repeat-expr: count

  ndict:
    params:
      - id: count_type
        type: u4
      - id: entry_type
        type: u4
    seq:
      - id: count
        type:
          switch-on: count_type
          cases:
            1: u1
            2: u2
            4: u4
      - id: entries
        type:
          switch-on: entry_type
          cases:
            0: entry_str_str
            1: entry_str_u1
            2: entry_str_u2
            4: entry_str_u4
            256: entry_u2_str
        repeat: expr
        repeat-expr: count

  dict:
    params:
      - id: len
        type: u4
      - id: entry_type
        type: u4
    seq:
      - id: entries
        type:
          switch-on: entry_type
          cases:
            0: entry_str_str
            1: entry_str_u1
            2: entry_str_u2
            4: entry_str_u4
            256: entry_u2_str
        repeat: expr
        repeat-expr: len

  entry_str_u1:
    seq:
      - id: label
        type: smart_types::strl
      - id: value
        type: u1

  entry_str_u2:
    seq:
      - id: label
        type: smart_types::strl
      - id: value
        type: u2

  entry_str_u4:
    seq:
      - id: label
        type: smart_types::strl
      - id: value
        type: u4

  entry_str_str:
    seq:
      - id: label
        type: smart_types::strl
      - id: value
        type: smart_types::strl

  entry_u2_str:
    seq:
      - id: label
        type: u2
      - id: strlen
        type: u2
      - id: value
        type: str
        size: strlen
        encoding: gbk
        # try this for now
        # type: smart_types::strl








































