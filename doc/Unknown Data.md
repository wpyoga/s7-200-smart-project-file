# Unknown Data

This block of data is found after CPU information block.

Notes:

- these look like library subroutines, or built-in tables, or maybe wizard data
- PID 0...15 are mentioned
- configured HSC are known by their renamed HSCs
- EXTERN_RESET, DIR_CHANGE, COUNT_EQ are mentioned, seems related to HSC

## What we know so far

- 1 byte: 01
- 4 bytes null
- variable block of data
  - 9 bytes: v2.x
    - 1 byte: 03
    - 8 bytes: 10 00 00 00 00 00 00 00
  - 1 byte: v1.x template
    - 1 byte: 01

- maybe extra project info
  - project name string
    - 2 bytes length (sometimes 00 00, then no name encoded)
    - n bytes string
  - 2 bytes null
  - 1 byte: 01
  - 4 bytes null
  - 16 bytes hash
    - looks like MD5
    - not sure what to hash


- 4 bytes null
- profinet wizard
  - 1 byte: 01
  - 1 byte: 01
  - 2 bytes: start up time (ms)
    - 10 27 = 10000
  - 2 bytes null
  - 2 bytes: profinet device configuration bit flag
    - not configured: 00 00
    - controller: 02 00
    - i-device: 04 00
  - 2 bytes null
  - 4 bytes: parameter assignment of profinet interface by higher-level IO controller
    - 01 00 00 00: not enabled
    - 00 00 00 00: enabled
  - 1 byte: 01
  - 4 bytes: send clock (ms)
    - 00 00 80 3f = 1.000 (floating point)
  - profinet configuration
    - not configured
      - 22 bytes null
      - 1 byte: 01
      - 22 bytes null
      - 4x 5 bytes
        - 1 byte: 01
        - 4 bytes null
    - configured example
      - string: station name
        - 2 bytes length: 0c 00
        - string: station-name
      - 4 bytes ip address (little endian)
      - 4 bytes netmark (little endian)
      - 4 bytes default gateway (little endian)
      - 1 byte: ???
        - 02 -> controller?
        - 03 -> i-device?
      - 4 bytes null
      - 1 byte: number of transfer areas
      - transfer areas
        - 1 byte null
        - 4 bytes: subslot
        - 4 bytes: length
        - transfer area name
          - 2 bytes length
          - string
        - comment
          - 2 bytes length
          - string
        - 3 bytes: 02 03 02
        - 4 bytes: input/output ???
          - 02 00 00 00: output
          - 01 00 00 00: input
        - 4 bytes: address offset
      - export GSDML file information
        - designation
          - 2 bytes length
          - string
        - description
          - 2 bytes length
          - string
      - 6 bytes null
      - 4 bytes length of following block ???
      - block
        - not sure how to decode
        - if block length is 0x74, first byte is 0x20
        - if block length is 0x54, first byte is 0x08
      - 368 bytes unknown --> looks like profinet config that can be exported to GSDML
        - 145 bytes unknown
        - number of transfer areas x 24 bytes (BIG ENDIAN)
          - 2 bytes subslot
          - 2 bytes null
          - 1 byte input/output
            - 10 00: input
            - 20 00: output
          - 2 bytes: number of bytes in transfer area
          - 4 bytes: input/output
            - 81 00 00 00: output
            - 82 00 00 00: input
          - 1 byte: input/output
            - 10: output
            - 00: input
          - 2 bytes: number of bytes in transfer area
          - 4 bytes: 00 01 00 01
          - 4 bytes null
        - 103 bytes unknown
      - 1 byte: number of following records (related to transfer area)
      - transfer area config / records (all in BIG ENDIAN)
        - 2 bytes subslot
        - 4 bytes input offset
          - ff ff ff ff -> not input transfer area
          - 00 00 24 00 -> 1152
        - 4 bytes output offset
          - ff ff ff ff -> not input transfer area
          - 00 00 24 00 -> 1152
          - 00 00 24 40 -> 1160
          - 00 00 24 48 -> 1161
          - 00 00 24 50 -> 1162
        - 4 bytes null
        - 1 byte: 01
        - 22 bytes null
        - 4x 5 bytes
          - 1 byte: 01
          - 4 bytes null


## Another unknown block
- unknown block
  - 1 byte: 02
  - 16 bytes null
  - 2 bytes: 1b 00

## A possible second PID block

- possibly another PID block
  - 1 byte: 02
  - 4 bytes number of PID: 10 00 00 00 = 16
  - 1 byte: 04
  - 1 byte: 02
  - 10 bytes null
  - 16x 347 bytes PID info
    - 2 bytes: 80 bf
    - 6 bytes null
    - 2 bytes: 20 41
    - 10 bytes null
    - 2x 4 bytes: c8 42 00 00
    - 82 bytes null
    - 2x 8 bytes
      - 7 bytes null
      - 1 byte 40
    - 2 bytes: 01 00
    - 8 bytes null
    - 1 byte: 6c
    - 6 bytes null
    - 4 bytes: cd cc cc 3d
    - 8x 11 bytes
      - 3 bytes: 02 03 40
      - bytes null
    - 100 bytes null
- 88 bytes null


## At the end of the project file

- 16 bytes null
