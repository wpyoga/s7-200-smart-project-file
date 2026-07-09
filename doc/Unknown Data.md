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
