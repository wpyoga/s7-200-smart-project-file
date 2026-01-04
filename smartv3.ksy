meta:
  id: smartv3
  title: SMART V3 project file 
  file-extension: smartV3
  ks-version: 0.11
  endian: le
  bit-endian: le
seq:
  - id: header
    type: header
  - id: zip_encrypted
    type: encrypted_body
types:
  header:
    seq:
      - id: null_signature
        type: u4
        valid: 0
      - id: file_version
        type: str
        size: 12
        encoding: ascii
        valid:
          any-of: ['"R03.00.00.00"', '"R03.01.00.00"']
      - type: null(105)
      - id: project_protection_flags
        type: u1
        valid:
          any-of: [0x02, 0x01]
      - type: null(134)
  encrypted_body:
    seq:
      - id: body
        size-eos: True
  null:
    params:
      - id: len
        type: u4
    seq:
      - id: zero
        type: u1
        repeat: expr
        repeat-expr: len
