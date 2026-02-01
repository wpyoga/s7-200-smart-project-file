meta:
  id: status_chart
  endian: le
  imports:
    - smart_types


seq:
  # - size: 0x77cd
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

  entry:
    seq:
      - id: index
        type: u2
      - id: marker
        type: u4
        valid: 0x01030201
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
        type: u2
        valid: 1
      - id: flag_2
        type: u2
        valid: 1
      - id: address_or_name
        type: smart_types::strl1




















