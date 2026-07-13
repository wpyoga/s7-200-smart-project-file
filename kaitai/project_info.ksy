meta:
  id: project_info
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x2cf54

  - type: smart_types::nulls(1)

  - id: name
    type: smart_types::strl

  - type: u2
    valid: 0

  - type: u1
    valid: 1

  - type: u4
    valid: 0

  - id: maybe_hash
    size: 16

  - type: u1
    valid: 1

  - type: smart_types::nulls(4)











