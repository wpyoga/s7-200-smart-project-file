# Expansion Module

Expansion modules are stored in a common (versioned) format.

The first 8 bytes describe the module, and whether it is present / configured:
- 4 bytes: expansion module if configured, or garbage data otherwise
- 4 bytes:
    - 01 00 00 00 if configured
    - 00 00 00 00 if not configured

Block version depends on the software version, while expansion module version depends on the series.
For example, 0AA0 and 0AA1 series modules will have different identifiers. However, the block version
depends on the software version.

As a general rule:
- V2.x software supports 0AA0 modules
  - because only 0AA0 modules are supported by v1.x and v2.x CPUs
- V3.x software supports 0AA0 and 0AA1 modules
  - because v3.0 CPU supports 0AA0 modules while ST32 supports 0AA1 modules

## No expansion module

The data looks like this
- 4 bytes null or garbage data: 4c 60 cd 67
- 4 bytes null -> not configured

## DP01

293 bytes

- 4 bytes: 01 40 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> offset
- 4 bytes: 08 00 00 \-\> offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes: 01 00 00 00
- 4 bytes: 01 40 00 80
- 2 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 02
- array
  - 2 bytes length: 20 00
  - 2 bytes null
  - 32 x2 bytes: digital input config??
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 20 00
  - 2 bytes null
  - 32 x4 bytes null
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

# DE08

39 bytes

- 4 bytes: 00 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 00 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 02
- array
  - 2 bytes length: 08 00
  - 2 bytes null
  - 8 x2 bytes: digital input config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## DE16

39 bytes

- 4 bytes: 16 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 16 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 02
- array
  - 2 bytes length: 10 00
  - 2 bytes null
  - 16 x2 bytes: digital input config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## DT08

39 bytes

- 4 bytes: 01 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 01 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 08 00
  - 2 bytes null
  - 8 x4 bytes: null, maybe output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## DR08

39 bytes

- 4 bytes: 02 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 02 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 08 00
  - 2 bytes null
  - 8 x4 bytes: null, maybe output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## QT16

135 bytes

- 4 bytes: 17 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 17 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 10 00
  - 2 bytes null
  - 16 x4 bytes: null, maybe output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## QR16

135 bytes

- 4 bytes: 18 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 18 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 10 00
  - 2 bytes null
  - 16 x4 bytes: null, maybe output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## DT16

129 bytes

- 4 bytes: 03 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 03 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 02
- array
  - 2 bytes length: 08 00
  - 2 bytes null
  - 8 x2 bytes: input config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 08 00
  - 2 bytes null
  - 8 x2 bytes: null, maybe output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## DR16

129 bytes

- 4 bytes: 04 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 04 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 02
- array
  - 2 bytes length: 08 00
  - 2 bytes null
  - 8 x2 bytes: input config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 08 00
  - 2 bytes null
  - 8 x2 bytes: null, maybe output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## DT32

177 bytes

- 4 bytes: 05 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 05 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 02
- array
  - 2 bytes length: 10 00
  - 2 bytes null
  - 16 x2 bytes: input config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 10 00
  - 2 bytes null
  - 16 x4 bytes: null, maybe output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## DR32

177 bytes

- 4 bytes: 06 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 08 00 00 \-\> input image offset
- 4 bytes: 08 00 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 06 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 2 bytes: 00 02
- array
  - 2 bytes length: 10 00
  - 2 bytes null
  - 16 x2 bytes: input config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 10 00
  - 2 bytes null
  - 16 x4 bytes: null, maybe output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AE04

176 bytes

- 4 bytes: 07 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 30 00 3E 00 \-\> input image offset
- 4 bytes: 30 00 3E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 07 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 01
- array
  - 2 bytes length: 04 00
  - 2 bytes null
  - 4 x26 bytes: input config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AE08

280 bytes

- 4 bytes: 13 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 40 00 4E 00 \-\> input image offset
- 4 bytes: 40 00 4E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 13 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 01
- array
  - 2 bytes length: 08 00
  - 2 bytes null
  - 8 x26 bytes: input config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AQ02

40 bytes

- 4 bytes: 08 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 50 00 5E 00 \-\> input image offset
- 4 bytes: 50 00 5E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 08 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 01
- array
  - 2 bytes length: 02 00
  - 2 bytes null
  - 2 x6 bytes: output config
- 4 bytes: 02 00 00 00
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AQ04

52 bytes

- 4 bytes: 15 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 60 00 6E 00 \-\> input image offset
- 4 bytes: 60 00 6E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 15 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 01
- array
  - 2 bytes length: 04 00
  - 2 bytes null
  - 4 x6 bytes: output config
- 4 bytes: 04 00 00 00
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AM03

145 bytes

- 4 bytes: 12 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 10 00 1E 00 \-\> input image offset
- 4 bytes: 10 00 1E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 12 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 01
- array
  - 2 bytes length: 02 00
  - 2 bytes null
  - 2 x26 bytes: output config
    - user power alarm is encoded as a bit in each channel here
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 01 00
  - 2 bytes null
  - 1 x6 bytes: output config
    - user power alarm is also encoded as a bit in each channel here
- 4 bytes: 01 00 00 00
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AM06

203 bytes

- 4 bytes: 09 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 20 00 2E 00 \-\> input image offset
- 4 bytes: 20 00 2E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 09 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 01
- array
  - 2 bytes length: 04 00
  - 2 bytes null
  - 4 x26 bytes: output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- array
  - 2 bytes length: 02 00
  - 2 bytes null
  - 2 x6 bytes: output config
- 4 bytes: 02 00 00 00
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AR02

124 bytes

- 4 bytes: 10 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 50 00 5E 00 \-\> input image offset
- 4 bytes: 50 00 5E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 10 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 01
- array
  - 2 bytes length: 02 00
  - 2 bytes null
  - 2 x26 bytes: output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AR04

176 bytes

- 4 bytes: 14 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 50 00 5E 00 \-\> input image offset
- 4 bytes: 50 00 5E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 14 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 01
- array
  - 2 bytes length: 04 00
  - 2 bytes null
  - 2 x26 bytes: output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01

## AT04

176 bytes

- 4 bytes: 11 30 00 80
- 4 bytes: 01 00 00 00
- 1 byte: 06
- 4 bytes: 01 00 00 00
- 4 bytes: 50 00 5E 00 \-\> input image offset
- 4 bytes: 50 00 5E 00 \-\> output image offset
- 4 bytes null
- 4 bytes EM number
- 8 bytes null
- 4 bytes null
- 4 bytes: 11 30 00 80
- 4 bytes: 03 00 00 00
- 4 bytes: EM number
- 2 bytes: 00 03
- 4 bytes: 01 00 00 00
- 1 byte null
- 2 bytes: 00 00
- array
  - 2 bytes length: 04 00
  - 2 bytes null
  - 2 x26 bytes: output config
- 4 bytes: 01 00 00 00
- 2 bytes: 00 01
- if leftover data
- 4 bytes: previous marker
  - 01 40 00 80
  - 00 30 00 80
- 4 bytes: null

## AT08

