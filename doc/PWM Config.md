# PWM Config

- PWM config
  - 1 byte: 01
  - 4 bytes number of records: 04 00 00 00
  - 4x 59 byte records
    - 1 byte: 01
    - 4 bytes null
    - 2 bytes index: 00 00, 01 00, ...
    - 4 bytes null
    - 4 bytes: 01 00 00 00
    - 4x 11 bytes
      - 3 bytes: 02 03 40
      - 8 bytes null
