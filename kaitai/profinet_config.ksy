meta:
  id: profinet_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x5eb67
  # - size: 0x5ecae

  # - id: profinet_data
  #   size: 78202
  #   size: 35682

  - id: marker
    type: u1
    valid: 1

  - id: marker_2
    type: u1
    valid: 1

  - id: start_up_time
    type: u4

  - id: profinet_device_config
    type: u4
    # this is a bit field
    # 00 00 00 00: not configured
    # 02 00 00 00: controller
    # 04 00 00 00: i-device

  - id: parameter_assignment_by_higher_level_io_controller
    type: u4

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
    # size: 32403

  # - id: idevice_config
  #   type: idevice_config

  # - id: precompiled_profinet_block
  #   type: precompiled_profinet_block


types:

  # looks like precompiled profinet config for the PLC
  # this block is big-endian, matching the PLC endianness
  # while other blocks are little-endian, matching PC endianness
  precompiled_profinet_block:
    meta:
      endian: be
    seq:
      - size: 596

      - id: precompiled_sub_block
        type: precompiled_sub_block
        repeat: expr
        repeat-expr: 2
        # todo: find this info somewhere

  precompiled_sub_block:
    meta:
      endian: be
    seq:
      - size: 48
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


      - type: smart_types::strl_be
      - size: 9
      - type: smart_types::strl_be
      - id: subslot_1
        type: u2
      - id: flag_1
        type: u2
      - id: size_1
        type: u2
      - type: smart_types::strl_be
      - id: subslot_2
        type: u2
      - id: flag_2
        type: u2
      - id: size_2
        type: u2
      - type: smart_types::strl_be
      - size: 27
      - id: plant_designation
        type: smart_types::strn(32)
      - id: location_designation
        type: smart_types::strn(22)
      - size: 26
      - id: installation_date
        type: smart_types::strn(32)
      - size: 10
      - id: additional_information
        type: smart_types::strn(54)
      - size: 16
      - id: name_len
        type: u2
      - type: u2
      - id: dev_name
        size: name_len
      - size: 18
      - id: ip_address_2
        type: smart_types::ipv4_addr
      - id: netmask
        type: smart_types::ipv4_addr
      - id: ip_address_3
        type: smart_types::ipv4_addr
      - size: 19







  controller_config_block:
    seq:
      - id: num_controller
        type: u1
      - id: controller_config
        type: controller_config
        repeat: expr
        # repeat-expr: num_controller
        repeat-expr: 1

  controller_config:
    seq:
      - type: u4
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
      - type: u1
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
      - type: u1
      - type: smart_types::strl
      - type: u2
      - type: smart_types::strl
      - type: u2
      - type: smart_types::strl
      - type: u2
      - type: smart_types::strl
      - type: u2
      - type: smart_types::strl
      - type: u2
      - type: smart_types::strl
      - type: u4
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
      - type: u1
      - type: smart_types::strl
      - type: u2
      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
      - type: smart_types::strl
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

      - id: count_2
        type: u1
      - type: dict(count_2, 0)

      - id: count_3
        type: u1
      - type: dict(count_3, 4)

      - id: count_4
        type: u1
      - type: dict(count_4, 1)

      - type: u1

      - id: count_5
        type: u1
      - type: list(count_5, 0)

      - id: count_6
        type: u1
      - type: dict(count_6, 0)

      - id: count_7
        type: u1
      - type: dict(count_7, 0)

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

      - id: count_8
        type: u1
      - type: dict(count_8, 0)

      - type: u1

      - id: count_9
        type: u1
      - type: dict(count_9, 0)

      - type: u4
      - type: u4

      - type: u1

      - id: count_10
        type: u1
      - type: dict(count_10, 0)

      - id: count_11
        type: u1
      - type: dict(count_11, 0)

      - id: count_12
        type: u1
      - type: dict(count_12, 1)

      - id: count_13
        type: u1
      - type: dict(count_13, 2)

      - type: u1
      - type: u4
      - type: u4

      - id: count_14
        type: u1
      - type: dict(count_14, 0)

      - id: count_15
        type: u1
      - type: dict(count_15, 4)

      - type: u2

      - id: count_16
        type: u1
      - type: dict(count_16, 0)

      - id: count_17
        type: u1
      - type: dict(count_17, 2)



































  idevice_config:
    seq:
      - type: smart_types::nulls(4)

      - id: num_transfer_area
        type: u1

      - id: transfer_area
        type: transfer_area
        repeat: expr
        repeat-expr: num_transfer_area

      - type: smart_types::strl
      - type: smart_types::strl




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
      - id: value
        type: smart_types::strl









































