# microwin smart 2.8.2

## smart project file format

- saving multiple times don't change the bytes
- small changes in-app leads to almost whole file changes
  - deletion of an empty network sometimes leads to file size increasing
  - seems like some kind of compression, and/or encryption
  - removing a network and then adding it back results in different file data
- seems to be in little-endian
  - all 2-byte sequences are in little endian byte order
- doesn't seem to contain any timestamp
  - previous versions have a problem with project timestamp, investigate this
- project password protection is based on password authentication
  - zlib stream is unchanged
  - password is salted then hashed
  - salt is stored in the file
  - when file is opened, the program asks for password
  - if password is correct, the file is loaded, otherwise a new empty project is opened instead

## project file structure

- 4 bytes header
  - `SH3\0` -> R02.04.00.00
  - `DEM\0` -> R01.00.00.00
- 12 bytes version
  - R02.04.00.00 -> saved by MicroWin SMART v2.8
  - R01.00.00.00 -> original template file
- 26 null bytes
- 2 bytes salt
  - if salt is 00 00, and password hash is all null, file is not password-protected
  - salt is appended to password, i.e. sha512("password"+"salt")
- password hash
  - R02.04.00.00
    - 64 bytes: SHA-512 of password+salt
  - R01.00.00.00
    - 20 bytes: SHA-1 of password+salt ??? maybe, need to confirm
- 4 bytes, little endian number of bytes of uncompressed stream
- zlib compressed stream

### zlib stream

- seems to be a single stream inside the .smart project file
- can be decompressed by zlib-flate (give -uncompress flag)
- can be recompressed by zlib-flate -compress=6
  - 6 is the default compression ratio, which gives us the 789c header
  - stream can be recompressed with a higher or lower compression ratio, and it seems to be decoded just fine
- contains file name. if file is renamed, the name is stored inside this stream
- doesn't seem to contain any checksum on the data as a whole
  - only some parity info
  - and surely some timestamp info
- if a symbol table is added then deleted, a counter is incremented
- strings are encoded with a length first, then number of bytes following
  - 1 byte length + up to 255 bytes
  - 2 byte length + up to 65535 bytes
  - the terminating null byte is not counted and not stored
  - the string encoding follows the current windows codepage
- project tree open status is not saved
- subroutine editor open status is saved
  - subroutine editor mode (LAD, FBD, STL) is saved
- data is read in like a stream
  - marker / type identifier
  - we need to know how to read each type, they are different

## uncompressed stream

- header
  - 1 byte editor version: 1c
    - 1c = 28 = Micro/WIN SMART v2.8
    - 1b = 27 = Micro/WIN SMART v2.7
    - 1a = 26 = Micro/WIN SMART v2.4
    - 18 = 24 = Micro/WIN SMART v2.4 & v2.5
      - sometimes it doesn't match the version string
    - 12 = original template project file
      - comes with R01.00.00.00 version in the compressed file
  - encoded version
    - 8 bytes: R02.04.00.00
      - 2 bytes: d0 00
        - d0 00 = 0208 = V02.08
        - cf 00 = 0207 = V02.07 but also 2.02
        - ce 00 = 0206 = V02.06
        - cd 00 = 0205 = V02.05
      - 2 bytes: c9 00
        - c9 00 = 0201 = 02.01
        - 00 00 = 0000 = 00.00
      - 2 bytes: 03 00
        - 03 00 = 0003 = 00.03
        - 02 00 = 0002 = 00.02
        - 0b 00 = 0011 = ??
          - sometimes it doesn't match the version string
      - 2 bytes: 01 00
        - 01 00 = 0001 = 00.01
    - 4 bytes: R01.00.00
      - 00 01 00 20: corresponding to 4.0.0.46 software version string
        - 20 hex = 32 dec = 40 oct
        - 46 oct = 38 dec
        - 40 oct = 32 dec
        - 46 dec = 56 oct = 2E hex = 00101110 bin
        - not sure how this version is encoded
- 1 byte: 03
- 8 bytes connection info
  - 4 byte: Modbus station number for Port0
  - 4 bytes IP address
    - 4 IPv4 octets in normal order
    - not 32-bit encoded IP address
    - this is the last connected PLC IP address
    - if system block is opened and closed, this is cleared
- 1 byte null
- Micro/WIN SMART software version (used to save this file)
  - 2 bytes: 18 00 (string length) -> 0x0018 = 24
  - string: V02.08.02.01_00.03.00.01
  - sometimes this is an unknown version string
  - template file version string: 4.0.0.46
    - this looks like MicroWin v4.0 SPxxx
    - makes sense since S7-200 SMART is derived from S7-200
- 1 byte null
- project file name without .smart extension
  - this changes if the project name changes
  - 2 bytes: 0b 00 (string length) -> 0x000b = 11
  - string: Project1xyz
- 1 byte null
- 1 byte: view mode
  - 00: LAD
  - 01: STL
  - 02: FBD
- 3 bytes null
- [printer information](Printer%20Information.md)
- timestamps
  - 16 bytes timestamp (creation time?)
  - 16 bytes timestamp (last modified?) -> this is updated whenever a symbol table is updated
  - 1 byte: 01
  - 16 bytes timestamp -> this is also updated whenever a symbol table is updated
  - 16 bytes timestamp -> this is updated whenever a data page is updated or created
- [system block](System%20Block.md)
- timestamps
  - 1 byte version
    - 01: R02.04.00.00
    - 00: R01.00.00.00
  - timestamp 1
  - timestamp 2 -> this is updated whenever a symbol table or program block is updated
  - timestamp 3
  - timestamp 4 -> this is updated whenever a data page is updated or created (or symbol table is updated/added/removed)
- [program block](Program%20Block.md)
- [symbol tables](Symbol%20Table.md)
- [status charts](Status%20Chart.md)
- [data block](Data%20Block.md)
- 1 byte null
- [CPU information](CPU%20Information.md)
- 2 bytes null
- project name string
  - 2 bytes length (sometimes 00 00, then no name encoded)
  - n bytes string
- 2 bytes null
- 1 byte: 01
- 4 bytes null
- 16 bytes hash
  - looks like MD5
  - not sure what to hash
- [unknown data](Unknown%20Data.md)

## misc info & notes

### general notes

- usually, strings have 2 byte lengths (without trailing null)
- likewise, records usually have 2 byte lengths
- integers, offsets, values are usually stored as a 32-bit number
- blocks usually have an ending null byte
- index of positive and negative transitions are not stored inside the project file (they are stored in the CPU)
- Symbol Tables have a minimum number of 1
  - POU Symbols can't be edited nor deleted
- Status Charts have a minimum number of 1
- Data Pages have a minimum number of 1

### CPU versions

- ST and SR series are the standard CPU models
  - 20 30 40 60
  - v1.x to v2.x
- CR series are the lite models
  - CR60: v2.0 v2.1 v2.2
  - CR40: v1.x to v2.0 v2.1 v2.2
  - v2.2 has multiple sub-versions: v2.2.0 v2.2.1 v2.2.2 v2.2.3 v2.2.4
    - no discernible differences exist though
- CR..s series are newer lite models
  - 20 30 40 60
  - v2.3 only

### numeric values

- broadly divided into whole numbers and decimal numbers
- almost always stored as 4 bytes
- whole numbers are further divided into
  - bit: this is 0 or 1
  - byte
  - word / unsigned int
  - int
  - dword / unsigned dint
  - dint
- decimal numbers are stored as a single-precision float value

#### integer constants

- x \< -32768 is negative DINT
- -32768 \<= x \< -128 is negative INT
- -128 \<= x \< 0 is negative BYTE
- 0 \<= x \< 2 is BIT
- 2\<= x \< 128 is positive small BYTE
- 128 \<= x \< 256 is positive BYTE
- 256 \<= x \< 32768 is positive small INT
- 32768 \<= x \< 65536 is positive INT
- 65536 \<= x \< 2147483648 is positive small DINT
- 2147483648 \<= x \< 4294967295 is positive DINT

### timestamp is always 16 bytes

- 2 bytes year
- 2 bytes month
- 2 bytes -- unknown
- 2 bytes day of month
- 2 bytes hour
- 2 bytes minutes
- 2 bytes second
- 2 bytes milliseconds
