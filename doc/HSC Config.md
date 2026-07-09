# HSC Config

- HSC wizard block
  - 1 byte: 04
  - 4 bytes: 04 00 00 00
  - 4 bytes number of HSC: 06 00 00 00
  - 6x 120+ bytes HSC data
    - 2 bytes: 04 01
    - 4 bytes null
    - 1 byte: 01
    - string: name of HSC0 init subroutine
      - 2 bytes length, is 0 if wizard not configured
      - string: PG1_INIT for example
    - 2 bytes null
    - 4 bytes: 01 02 08 01
    - nulls
      - 1 byte length: 0a = 10
      - 10 bytes null
    - 4 bytes: 01 02 08 01
    - 24 bytes null
    - 2 bytes: 00 01
    - 4 bytes null
    - string
      - 2 bytes length: 0d 00 = 13
      - 13 bytes: EXTERN_RESET0, EXTERN_RESET1, ...
      - sometimes 12 bytes with no number suffix
    - 4 bytes null
    - string
      - 2 bytes length: 0b 00 = 11
      - 11 bytes: DIR_CHANGE0, DIR_CHANGE1, ...
    - 4 bytes null
    - string
      - 2 bytes length: 09 00 = 9
      - 9 bytes: COUNT_EQ0, COUNT_EQ1, ...
      - sometimes 8 bytes with no number suffix
    - 4 bytes null
    - 4 bytes flag: 01 00 00 00 if HSC configured or renamed?
    - 4 bytes HSC index: 00 00 00 00, 01 00 00 00, ...
    - string: HSC renamed
      - 1 byte length: 03 for example, can be 00 which means HSC is not renamed
      - string: PG1 for example
    - 4 bytes: some flag
        - only present in second block
    - 4 bytes: another flag
        - only present in second block
        - 00 00 00 00: previous flag is 1
        - ff ff ff ff: previous flag is 0


## Second Block

Second block is located near the end of the project file. It is basically the same format (confirmed) and
contains virtually the same data (to be confirmed).

The main difference is the 2 flags at the end of each HSC data (see above)
