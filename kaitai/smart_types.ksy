meta:
  id: smart_types
  endian: le

types:
  # string prefixed with 2-byte length, no null terminator
  strl:
    seq:
      - id: len
        type: u2
      - id: contents
        type: str
        size: len
        encoding: ASCII

  strl1:
    seq:
      - id: len
        type: u1
      - id: contents
        type: str
        size: len
        encoding: ASCII

  unknown:
    params:
      - id: len
        type: u4
    seq:
      - size: len

  nulls:
    params:
      - id: len
        type: u4
    seq:
      - type: u1
        repeat: expr
        repeat-expr: len
        valid: 0

  null1:
    seq:
      - contents: [0x00]

  sha512:
    seq:
      - size: 64

  sha1:
    seq:
      - size: 20

  ipv4_addr:
    seq:
      - id: octet1
        type: u1
      - id: octet2
        type: u1
      - id: octet3
        type: u1
      - id: octet4
        type: u1

  timestamp:
    seq:
      - id: year
        type: u2
      - id: month
        type: u2
      - id: day_of_week
        type: u2
      - id: day
        type: u2
      - id: hour
        type: u2
      - id: minute
        type: u2
      - id: second
        type: u2
      - id: millisecond
        type: u2

  u1_val:
    params:
      - id: req
        type: u1
    seq:
      - id: val
        type: u1
        valid: req

  u2_val:
    params:
      - id: req
        type: u2
    seq:
      - id: val
        type: u2
        valid: req

  u4_val:
    params:
      - id: req
        type: u4
    seq:
      - id: val
        type: u4
        valid: req

  rec:
    params:
      - id: len_size
        type: u4
      - id: rec_size
        type: u4
    seq:
      - id: len
        type:
          switch-on: len_size
          cases:
            4: u4
            2: u2
            1: u1
      - id: data
        size: rec_size
        repeat: expr
        repeat-expr: len



enums:
  enable_disable:
    0x01: enable
    0x00: disable

  baud_rate:
    1: bps_9600
    2: bps_19200
    4: bps_187500





