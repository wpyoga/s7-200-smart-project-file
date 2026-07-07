meta:
  id: unknown_data10
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8bf2c

  - type: smart_types::nulls(2)

  - id: some_name
    type: smart_types::strl

  - type: smart_types::nulls(2)

  - type: u1
    valid: 1

  - type: smart_types::nulls(4)

  - id: maybe_hash
    size: 16


