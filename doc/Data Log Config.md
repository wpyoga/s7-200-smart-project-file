# Data Log Config

- data log config
  - 1 byte: 01
  - 4 bytes: 83 00 00 00
  - 4 bytes number of records: 04 00 00 00
  - 4 records of 36 bytes each
    - 1 byte: 03
    - 4 bytes null
    - 2 bytes index: 00 00, 01 00, ...
    - 8 bytes null
    - 4 bytes: 01 01 00 00
    - 2 bytes: 00 01
    - 7 bytes null
    - 2 bytes: e8 03
    - 6 bytes null
