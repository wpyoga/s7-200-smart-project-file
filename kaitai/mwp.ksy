meta:
  id: mwp
  title: MicroWIN project file
  file-extension: mwp
  endian: le
  imports:
    - smart_types

seq:
  - id: header
    type: header
  - id: body
    size-eos: true

types:

  header:
    seq:
      - id: signature
        type: str
        size: 4
        encoding: ASCII
        valid:
          any-of:
            - '"GJK\0"'
      - id: file_version
        type: str
        size: 6
        encoding: ASCII
        valid:
          any-of:
            - '"R04.00"'
      - type: smart_types::nulls(26)
      - type: u4
        valid: 0x0000aaaa
        repeat: expr
        repeat-expr: 4
        # this block might be a password hash, but we don't have enough info for now
      - id: uncompressed_len
        type: u4

  body:
    seq:
      - id: body
        size-eos: True
