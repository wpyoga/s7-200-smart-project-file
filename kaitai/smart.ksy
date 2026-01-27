meta:
  id: smart
  title: SMART project file
  file-extension: smart
  ks-version: 0.11
  endian: le
  bit-endian: le
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
            - '"DEM\0"'
            - '"SH3\0"'
      - id: file_version
        type: str
        size: 12
        encoding: ASCII
        valid:
          any-of:
            - '"R01.00.00.00"'
            - '"R02.04.00.00"'
      - type: smart_types::nulls(26)
      - id: salt
        size: 2
      - id: password_hash
        type:
          switch-on: file_version
          cases:
            '"R01.00.00.00"': smart_types::sha1
            '"R02.04.00.00"': smart_types::sha512
      - id: uncompressed_len
        type: u4

  body:
    seq:
      - id: body
        size-eos: True
