meta:
  id: smart
  title: SMART project file 
  file-extension: smart
  ks-version: 0.11
  endian: le
  bit-endian: le
seq:
  - id: header
    type: header
  - id: body
    type: body
types:
  header:
    seq:
      - id: signature
        type: str
        size: 4
        encoding: ascii
        valid:
          any-of:
            - '"DEM\0"'
            - '"SH3\0"'
      - id: file_version
        type: str
        size: 12
        encoding: ascii
        valid:
          any-of:
            - '"R01.00.00.00"'
            - '"R02.04.00.00"'
      - type: null(26)
      - id: salt
        size: 2
      - id: password_hash
        type:
          switch-on: file_version
          cases:
            '"R01.00.00.00"': password_sha1
            '"R02.04.00.00"': password_sha512
      - id: uncompressed_len
        type: u4
  body:
    seq:
      - id: body
        size-eos: True
  password_sha512:
    seq:
      - size: 64
  password_sha1:
    seq:
      - size: 20
  null:
    params:
      - id: len
        type: u4
    seq:
      - id: zero
        type: u1
        repeat: expr
        repeat-expr: len
        valid: 0
