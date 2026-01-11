# Signal Board

Signal boards are stored in a common (versioned) format.

The first 8 bytes describe the signal board, and whether it is present / configured:
- 4 bytes: signal board if configured, or garbage data otherwise
- 4 bytes:
    - 01 00 00 00 if configured
    - 00 00 00 00 if not configured

Similar to expansion modules, the block version depends on the software version,
while expansion module version depends on the signal board series.
For example, 0AA0 and 0AA1 series signal boards will have different identifiers.
However, the block version depends on the software version, so 0AA0 and 0AA1 signal boards
can have the same block version on R03.

As a general rule:
- R02 software supports 0AA0 signal boards
  - because only 0AA0 signal boards are supported by v1.x and v2.x CPUs
- R03 software supports 0AA0 and 0AA1 signal boards
  - because v3.0 CPU supports 0AA0 signal boards while ST32 supports 0AA1 signal boards


## No signal board

The data looks like this
- 4 bytes null or garbage data:
    - 82 a6 a3 54
    - 82 a6 a3 66
    - 82 a6 4b 54
    - 82 a6 4b 66
    - d0 05 d8 01
    - 78 56 f9 04
    - ...
- 4 bytes null -> not configured

## SB DT04

- 4 bytes: 00 20 00 80
- 4 bytes: 01 00 00 00
- 1 byte: block version
  - 06: R02.04.00.00
- 32 bytes unknown
  - 4 bytes 01 00 00 00
  - 4 bytes 07 00 00 00
    - input start offset?
  - 4 bytes 07 00 00 00
    - output start offset?
  - 20 bytes null
- 8 bytes: 00 20 00 80 02 00 00 00
- 4 bytes null
- 1 byte null
- 5 bytes: 02 01 00 00 00
- 1 byte null
- signal board info
  - 1 byte 02
  - 2 bytes length: 02 00
  - 2 bytes null
  - n x2 bytes input config
    - starting from I7.0
    - same as cpu input config
  - 4 bytes: 01 00 00 00
  - 1 byte null
  - 1 byte 01
  - 2 bytes length
  - 2 bytes null
  - n x4 bytes output config
    - starting from Q7.0
    - same as cpu output config
- 6 bytes null
- 18 bytes null
- 8 bytes unknown: 02 02 00 00 00 01 00 00
- 10 bytes null
- 8 bytes unknown: 01 00 00 00 01 00 00 00

## SB AE01

- 4 bytes: 11 20 00 80
- 4 bytes: 01 00 00 00
- 1 byte: block version
  - 06: R02.04.00.00
- 32 bytes unknown
  - 4 bytes 01 00 00 00
  - 4 bytes 0C 00 0E 00 (input start offset and type?)
  - 4 bytes 0C 00 0E 00 (output start offset and type? but nonexistent on this module)
  - 20 bytes null
- 8 bytes: 11 20 00 80 02 00 00 00
- 4 bytes null
- 1 byte null
- 5 bytes: 02 01 00 00 00
- 2 bytes null
- signal board info
  - 1 byte 01
  - 2 bytes length: 01 00
  - 2 bytes null
  - 8 bytes info for AIW12 (only one)
    - input type
      - 01 09: voltage \+/- 10v
      - 01 08: voltage \+/- 5v
      - 01 07: voltage \+/- 2.5v
      - 03 02: current 0-20 ma
    - 1 byte null
    - 1 byte rejection & smoothing
      - bits 7-4: rejection
      - 3: 10 Hz
      - 2: 50 Hz
      - 1: 60 Hz
      - 0: 400 Hz
      - bits 3-0: smoothing
      - \-- 0: none
      - \-- 1: weak (4 cycles)
      - \-- 2: medium (16 cycles)
      - \-- 3: strong (32 cycles)
    - 00 00
    - 1 byte alarms (bitfield)
      - bit 7: upper
      - bit 6: lower
      - bits 5-0: unused
    - 1 byte null
- 18 bytes null
- 8 bytes unknown: 02 02 00 00 00 01 00 00
- 10 bytes null
- 8 bytes unknown: 01 00 00 00 01 00 00 00

## SB AQ01

- 4 bytes: 10 20 00 80
- 4 bytes: 01 00 00 00
- 1 byte: block version
  - 06: R02.04.00.00
- 32 bytes unknown
  - 4 bytes 01 00 00 00
  - 4 bytes 0C 00 0E 00 (input start offset and type?)
  - 4 bytes 0C 00 0E 00 (output start offset and type? but nonexistent on this module)
  - 20 bytes null
- 8 bytes: 10 20 00 80 02 00 00 00
- 4 bytes null
- 1 byte null
- 5 bytes: 02 01 00 00 00
  - freeze output: 02 01 01 00 00
- 2 bytes null
- signal board info
  - 1 byte 01
  - 2 bytes length: 01 00
  - 2 bytes null
  - 8 bytes info for AQW12 (only one)
    - 2 bytes output type
      - 01 00: voltage \+/- 10v
      - 03 01: current 0-20 ma
    - 1 byte null
    - 1 byte alarms (bitfield)
      - bit 7: upper
      - bit 6: lower
      - bit 5: unused
      - bit 4: wire break
      - bit 3: unused
      - bit 2: short circuit
      - bit 1: unused
      - bit 0: unused
    - 1 byte output config
      - no freeze output: 30
      - freeze output: 20
    - 2 bytes substitute value
    - 01 00
- 2 bytes null
- 8 bytes unknown: 02 02 00 00 00 01 00 00
- 10 bytes null
- 8 bytes unknown: 01 00 00 00 01 00 00 00

## SB BA01

- 4 bytes: 1D 20 00 80
- 4 bytes: 01 00 00 00
- 1 byte: block version
  - 06: R02.04.00.00
- 32 bytes unknown
  - 4 bytes 01 00 00 00
  - 4 bytes 07 00 00 00 (signal offset?)
  - 4 bytes 07 00 00 00 (signal offset?)
  - 12 bytes null
  - 4 bytes: 01 00 00 00
  - 4 bytes null
- 8 bytes: 1D 20 00 80 02 00 00 00
- 4 bytes null
- 1 byte null
- 5 bytes: 02 01 00 00 00
  - freeze output: 02 01 01 00 00
- 1 byte null
- signal board info
  - 1 byte 02
  - 2 bytes length: 01 00
  - 2 bytes null
  - 8 bytes info for AQW12 (only one)
    - 00 07
    - 02 02
    - 00 00
    - 00 01
- 2 bytes null
- 8 bytes unknown: 02 02 00 00 00 01 00 00
- 10 bytes null
- 4 bytes: alarm battery low
  - 01 00 00 00: enabled
  - 00 00 00 00: disabled
- 4 bytes: battery low status as I7.0
  - 01 00 00 00: enabled
  - 00 00 00 00: disabled

## SB CM01 0AA0

- 4 bytes: 1E 20 00 80
- 4 bytes: 01 00 00 00
- 1 byte: block version
  - 06: R02.04.00.00
- 32 bytes unknown
  - 4 bytes 01 00 00 00
  - 16 bytes null
  - 4 bytes: 01 00 00 00
  - 8 bytes null
- 8 bytes: 1E 20 00 80 02 00 00 00
- 4 bytes null -> position maybe?
- 1 byte null
- 5 bytes: 02 02 02 00 00
  - 2 bytes: 02 02
  - 1 byte: Modbus station address
  - 2 bytes: 00 00
- 1 byte null
- 1 byte: baud rate
  - 01: 9600
  - 02: 19200
  - 04: 187500
- 7 bytes null
- 1 byte type
  - 00: RS385
  - 01: RS232
- 12 bytes null

## SB CM01 0AA1

- 4 bytes: 1F 20 00 80
- 4 bytes: 01 00 00 00
- 1 byte: block version
  - 07: R03.01.00.00
- 32 bytes unknown
  - 4 bytes 01 00 00 00
  - 8 bytes null (slot 1) or unknown bytes (slot 2)
    - 2x 4 bytes: 10 02 12 02
  - 4 bytes null
  - 4 bytes position
    - 00 00 00 00: slot 1
    - 01 00 00 00: slot 2
  - 4 bytes: 01 00 00 00
  - 8 bytes null
- 8 bytes: 1F 20 00 80 02 00 00 00
- 4 bytes position
  - 00 00 00 00: slot 1
  - 01 00 00 00: slot 2
- 1 byte null
- 24 bytes unknown, only in version 07
  - 2x 8 bytes: 0c 00 00 00 0e 00 00 00 (slot 1) or 10 02 00 00 12 02 00 00 (slot 2)
  - 2x 4 bytes: 07 00 00 00 (slot 1) or 48 00 00 00 (slot 2)
- 5 bytes: 02 02 02 00 00
  - 2 bytes: 02 02
  - 1 byte: Modbus station address
  - 2 bytes: 00 00
- 1 byte null
- 1 byte: baud rate
  - 01: 9600
  - 02: 19200
  - 04: 187500
- 7 bytes null
- 1 byte type
  - 00: RS485
  - 01: RS232
- 12 bytes unknown
  - 4 bytes null
  - 2x 4 bytes: 01 00 00 00
