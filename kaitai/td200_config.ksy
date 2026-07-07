meta:
  id: td200_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8d71d
  # - size: 0x1bd07e

  - type: u1
    valid: 2

  - id: num_record
    type: u4

  - id: unknown_record
    type: unknown_record
    # size: 442
    # size: 96
    repeat: expr
    repeat-expr: num_record


types:
  unknown_record:
    seq:
      - id: marker
        type: u2
        valid: 0x0103

      - id: flags
        type: u4
        repeat: expr
        repeat-expr: 8

      - type: u1
        valid: 1

      - id: lang
        type: smart_types::strl

      - id: attr1
        type: u1
        # valid: 1

      - type: smart_types::nulls(4)

      - type: u1
        valid: 1

      - type: smart_types::nulls(2)

      - id: key_related_record
        type: key_related_record
        repeat: expr
        repeat-expr: 8
        if: attr1 == 1

      - type: smart_types::nulls(4)

      - type: u4

      - type: smart_types::nulls(8)

      - id: index
        type: u2

      - type: smart_types::nulls(2)

      - type: u2

      - type: smart_types::nulls(20)

      - type: u4

      - type: u4

      - type: u4




  key_related_record:
    seq:
      - type: smart_types::nulls(4)

      - type: u4

      - type: u1
        # valid: 1

      - id: index
        type: u2

      - id: key_name
        type: u2

      - type: u2
        # valid: 2

      - id: key_name_copy
        type: u2
        valid: key_name

      # - type: smart_types::nulls(8)
      - size: 8

      - type: u1
        # valid: 1

      - id: key_name_full
        type: smart_types::strl

      - id: key_name_abbrev
        type: smart_types::strl












































