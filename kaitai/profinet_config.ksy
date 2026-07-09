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

  - type: controller_config_block



types:
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
      - type: u2
      # - id: block_size_maybe
      #   type: u2
      # - size: block_size_maybe-2264
      - type: u2
      - type: u4
      - type: u4
      - type: u1
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
      - size: 45








  idevice_config:
    seq:
      - type: u1





































































