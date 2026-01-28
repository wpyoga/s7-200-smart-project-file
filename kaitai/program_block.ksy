meta:
  id: program_block
  endian: le
  imports:
    - pou

seq:
  # - size: 0x0be5
  # - size: 0x0768

  - id: version
    type: u1
    valid: 2

  - id: num_entries
    type: u2

  - id: pou
    type: pou
    repeat: expr
    repeat-expr: num_entries
