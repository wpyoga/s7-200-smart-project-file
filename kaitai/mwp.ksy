meta:
  id: mwp
  title: Micro/WIN project file
  file-extension: mwp
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
        valid: '"GJK\0"'

      - id: file_version
        type: str
        size: 6
        encoding: ASCII
        valid:
          any-of:
            - '"R03.20"'
            - '"R04.00"'

      - type: smart_types::nulls(26)
        if: file_version == "R04.00"

      - id: encoded_password_v4
        size: 16
        if: file_version == "R04.00"
        # max password length in app is also 16
        # no password: aa aa 00 00 x4

      - id: encoded_password_v3
        size: 10
        if: file_version == "R03.20"
        # no password: 00 cc 00 00 00 00 cc cc cc cc

      - type: smart_types::nulls(4)
        if: file_version == "R03.20"

      - id: uncompressed_len
        type: u4

  body:
    seq:
      - id: body
        size-eos: True
