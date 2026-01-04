# microwin smart 2.8.2

## smart project file format

* saving multiple times don't change the bytes
* small changes in-app leads to almost whole file changes
  * deletion of an empty network sometimes leads to file size increasing
  * seems like some kind of compression, and/or encryption
  * removing a network and then adding it back results in different file data
* seems to be in little-endian
  * all 2-byte sequences are in little endian byte order
* doesn't seem to contain any timestamp
  * previous versions have a problem with project timestamp, investigate this
* project password protection is based on password authentication
  * zlib stream is unchanged
  * password is salted then hashed
  * salt is stored in the file
  * when file is opened, the program asks for password
  * if password is correct, the file is loaded, otherwise a new empty project is opened instead

## V3

Notes
- V3 file format is slightly different.
- The compressed part seems to be compressed and then encrypted, somehow.
- The encryption key may be stored inside the file, or it may be stored within the executable.

## main file structure

* 4 bytes header
  * SH3\\0 \-\> R02.04.00.00
  * DEM\\0 \-\> R01.00.00.00
* 12 bytes version
  * R02.04.00.00 \-\> saved by MicroWin SMART v2.8
  * R01.00.00.00 \-\> original template file
* 26 null bytes
* 2 bytes salt
  * if salt is 00 00, file is not password-protected
  * salt is appended to password, i.e. sha512("password"+"salt")
* 64 or 20 bytes password hash
  * 64 bytes if R02.04.00.00 (SHA512)
  * 20 bytes if R01.00.00.00 (SHA1)
* 4 bytes, little endian number of bytes of uncompressed stream
* zlib compressed stream
  * in case of R03.00.00.00, this is not a simple zlib compressed stream

### zlib stream

* seems to be a single stream inside the .smart project file
* can be decompressed by zlib-flate (give \-uncompress flag)
* can be recompressed by zlib-flate \-compress=6
  * 6 is the default compression ratio, which gives us the 789c header
  * stream can be recompressed with a higher or lower compression ratio, and it seems to be decoded just fine
* contains file name. if file is renamed, the name is stored inside this stream
* doesn't seem to contain any checksum on the data as a whole
  * only some parity info
  * and surely some timestamp info
* if a symbol table is added then deleted, a counter is incremented
* strings are encoded with a length first, then number of bytes following
  * 1 byte length \+ up to 255 bytes
  * 2 byte length \+ up to 65535 bytes
  * the terminating null byte is not counted and not stored
  * the string encoding follows the current windows codepage
* project tree open status is not saved
* subroutine editor open status is saved
  * subroutine editor mode (LAD, FBD, STL) is saved
* data is read in like a stream
  * marker / type identifier
  * we need to know how to read each type, they are different

## uncompressed stream

* header
  * 1 byte editor version: 1c
    * 1c \= 28 \= Micro/WIN SMART v2.8
    * 1b \= 27 \= Micro/WIN SMART v2.7
    * 1a \= 26 \= Micro/WIN SMART v2.4
    * 18 \= 24 \= Micro/WIN SMART v2.4 & v2.5
      * sometimes it doesn't match the version string
    * 12 \= original template project file
      * comes with R01.00.00.00 version in the compressed file
  * encoded version
    * 8 bytes: R02.04.00.00
      * 2 bytes: d0 00
        * d0 00 \= 0208 \= V02.08
        * cf 00 \= 0207 \= V02.07
        * ce 00 \= 0206 \= V02.06
        * cd 00 \= 0205 \= V02.05
      * 2 bytes: c9 00
        * c9 00 \= 0201 \= 02.01
        * 00 00 \= 0000 \= 00.00
      * 2 bytes: 03 00
        * 03 00 \= 0003 \= 00.03
        * 02 00 \= 0002 \= 00.02
        * 0b 00 \= 0011 \= ??
          * sometimes it doesn't match the version string
      * 2 bytes: 01 00
        * 01 00 \= 0001 \= 00.01
    * 4 bytes: R01.00.00
      * 00 01 00 20: corresponding to 4.0.0.46 software version string
        * 20 hex \= 32 dec
        * 46 oct \= 38 dec
        * 40 oct \= 32 dec
        * 46 dec \= 56 oct \= 2E hex \= 00101110 bin
        * not sure how this version is encoded
* 1 byte: 03
* 8 bytes connection info
  * 1 byte: Modbus station number for Port0
  * 3 bytes null
  * 4 bytes IP address
    * 4 IPv4 octets in normal order
    * not 32-bit encoded IP address
    * this is the last connected IP address
    * if system block is opened and closed, this is cleared
* 1 byte null
* Micro/WIN SMART software version (used to save this file)
  * 2 bytes: 18 00 (string length) \-\> 0x0018 \= 24
  * string: V02.08.02.01\_00.03.00.01
  * sometimes this is an unknown version string
  * template file version string: 4.0.0.46
    * this looks like MicroWin v4.0 SPxxx
    * makes sense since S7-200 SMART is derived from S7-200
* 1 byte null
* project file name without .smart extension
  * this changes if the project name changes
  * 2 bytes: 0b 00 (string length) \-\> 0x000b \= 11
  * string: Project1xyz
* 1 byte null
* 1 byte: view mode
  * 00: LAD
  * 01: STL
  * 02: FBD
* 3 bytes null
* 1 byte: 01
* some data
  * 156 zero bytes \-\> R02.04.00.00
  * 148 bytes of data \-\> R01.00.00.00
    * 32 bytes name of last connected printer, padded with nulls
      * "\\\\99J192\\HP 2000C Printer"
    * then some 116 bytes of data
* 16 bytes data
  * 4x 4 bytes: 6e 04 00 00 \-\> R02.04.00.00
  * 2x 8 bytes: 08 07 00 00 a0 05 00 00 \-\> R01.00.00.00
* 10 bytes data
  * zero bytes \-\> R02.04.00.00
  * d0 2f 00 00 e0 3d 00 00 00 00
* 2x 2 bytes: 02 00
* 256 byte block
  * R02.04.00.00: starts with 24-byte string, no length encoded: %\[PROJECT\]  /  %\[OBJECT\]
    * double spaces in the middle
  * R01.00.00.00: starts with 21 byte string %\[PROJECT\], %\[OBJECT\]: R01.00.00.00
  * the rest of the bytes are all nulls
* 256-byte block
  * 7-byte string, no length encoded: %\[PAGE\]
  * 249 trailing null bytes
* 512 zero bytes
  * deleting all subroutines, interrupt routines, and removable symbol tables don't change anything here
* 2 bytes null
* some kind of info table
  * R02.04.00.00: 80 bytes bit field or records
    * record
      * 1 byte 01
      * 2 bytes length 08 00
      * n bytes record
    * 2 bytes null
    * record
      * 1 byte 01
      * 2 bytes length 08 00
      * n bytes record
    * 20 bytes unknown data or flags
    * 36 bytes data
      * 8 bytes null
      * 4 bytes: 01 00 00 01
      * 8 bytes null
      * 4 bytes: 00 01 00 00
      * 4 bytes: 01 00 00 00
      * 8 bytes null
  * R01.00.00.00: 88 bytes bit field of records
    * record
      * 1 byte 01
      * 2 bytes length 08 00
      * n bytes record
    * 2 bytes null
    * record
      * 1 byte 01
      * 2 bytes length 08 00
      * n bytes record
    * 28 bytes unknown data or flags
    * 36 bytes data
      * 8 bytes null
      * 4 bytes: 01 00 00 01
      * 8 bytes null
      * 4 bytes: 00 01 00 00
      * 4 bytes: 01 00 00 00
      * 8 bytes null
* timestamps
  * 16 bytes timestamp (creation time?)
  * 16 bytes timestamp (last modified?) \-\> this is updated whenever a symbol table is updated
  * 1 byte: 01
  * 16 bytes timestamp \-\> this is also updated whenever a symbol table is updated
  * 16 bytes timestamp \-\> this is updated whenever a data page is updated or created
* system block
  * 2 bytes: 0F 06
    * 0F 03: R01.00.00.00
  * null block
    * 44 bytes null: R02.04.00.00
    * 35 bytes null: R01.00.00.00
  * 2 bytes: 00 01
  * 1 byte: 02
  * 1 byte: Modbus station number for Port0
  * 3 bytes null
  * 1 byte: baud rate
    * 01: 9600
    * 02: 19200
    * 04: 187500
  * 8 bytes null
  * 4 bytes unknown: 00 00 00 01
  * 120 bytes: retentive ranges (from 0 to 5, 24 bytes each)
    * 4 bytes null
    * 4 bytes data width
      * 02 00 00 00: xB
      * 04 00 00 00: xW T
      * 08 00 00 00: xD C
    * 4 bytes memory location
      * 10 00 00 00 Vx
      * 20 00 00 00 Mx
      * 40 00 00 00 T
      * 80 00 00 00 C
    * 4 bytes offset
    * 4 bytes number of elements
  * 1 byte version:
    * 05: R02.04.00.00
    * 03: R01.00.00.00
  * 4 byte: CPU privileges
    * 01 00 00 00 full
    * 02 00 00 00 read
    * 03 00 00 00 minimum
    * 04 00 00 00 disallow upload
  * 4 bytes: serial port security
    * allow cpu mode change without password
    * allow time of day reads and writes without password
    * 01 00 00 00: allow
    * 00 00 00 00: no allow
  * mangled password or unknown data
    * 22 bytes: hashed & salted password \-\> R02.04.00.00
      * MD5 is 16 bytes
      * SHA1 is 20 bytes
      * maybe the salt is 2 bytes, with 20 bytes SHA1
    * 4 bytes: unknown \-\> R01.00.00.00
      * need V1.0 version software to test
      * might be a simple checksum
  * 1 bytes: 01
  * 1 byte: percentage of communications background time
    * default is 10% \= 0a
  * 3 bytes null
  * 1 byte 01
  * 4 bytes
    * startup mode: R02.04.00.00
      * 01 01 00 00: startup in RUN mode
      * 01 00 00 00: startup in STOP mode
      * 01 02 00 00: startup in LAST mode
    * always null: R01.00.00.00
  * 4 bytes: allow missing hardware
    * 01 00 00 00 allow
    * 00 00 00 00 no allow
  * 4 bytes: allow hardware configuration errors
    * 01 00 00 00 allow
    * 00 00 00 00 no allow
  * 1 byte: 03
  * 80 bytes IP address information
    * little endian
    * 4 bytes IP address status
      * fixed: 01 00 00 00
      * non fixed: 00 00 00 00
    * 4 bytes: 32-bit IP address
    * 4 bytes: 32-bit netmask
    * 4 bytes: 32-bit gateway
    * 64 bytes: station name including trailing null
  * 16 bytes null
  * CPU configuration
    * only on R02.04.00.00
    * 1 byte null
    * 4 bytes restrict communication writes
      * 01 00 00 00 restrict
      * 00 00 00 00 no restrict
    * 4 bytes V memory offset
    * 4 bytes number of bytes
    * 1 byte
      * 00 for ST
      * 01 for SR
      * 81 for CR..s
    * 2 bytes
      * 02 00 for xx20
      * 03 00 for xx30
      * 04 00 for xx40
      * 06 00 for xx60
    * 4 bytes: 80 06 01 00
    * 30 bytes null
    * 1 byte plc type
      * 00 for ST
      * 01 for SR
      * 81: for CR..s
    * 2 bytes
      * 02 00 for SR20
      * 03 00 for SR30 (see above)
      * 04 00 for SR40
      * 06 00 for SR60
    * 3 bytes: 80 01 00
    * 6 bytes null
    * PLC version string
      * only on R02.04.00.00
      * missing on R01.00.00.00
      * 1 byte length
      * PLC firmware version? V02.05.01\_00.00.01.00
        * sometimes there is a null byte following
        * if there is a null byte following, the previous length becomes 16 (24 dec)
        * this might be part of the system block
    * 6 bytes: 01 01 00 00 00 00
  * some data
    * only on R01.00.00.00
    * 1 byte null
    * 8 bytes unknown (null?)
    * 4 bytes: 64 00 00 00
    * 4 bytes null
    * 4 bytes: 03 00 00 00
    * 32 bytes null
    * 2 bytes: 00 01
  * cpu digital input config
    * only on R02.04.00.00
    * missing on R01.00.00.00
    * 1 byte type: 02
    * 2 bytes length
      * length \= number of entries \= number of inputs
      * SR20 \= 12 \= 0c
      * SR30 \= 18 \= 12
      * SR40 \= 24 \= 18
      * SR60 \= 36 \= 24
    * 2 bytes null
    * n x2 bytes CPU digital input configuration
      * starting from I0.0
      * 1 byte null
      * 1 byte bitfield
        * bit 7 \= filter ms or us
          * 0 \= ms
          * 1 \= us
        * bit 6 \= pulse catch
        * bits 5-0 \= digital input filter
          * e (hex) \= None
          * 9 \= 12.8 ms or us
          * 7 \= 6.4 ms or us
          * 6 \= 3.2 ms or us
          * 5 \= 1.6 ms or us
          * 4 \= 0.8 ms or us
          * 3 \= 0.4 ms or us
          * 2 \= 0.2 ms or us
  * cpu digital output config
    * only on R02.04.00.00
    * missing on R01.00.00.00
    * 1 byte: 01
    * 1 byte: freeze outputs in last state
      * 01: freeze
      * 00: no freeze
    * 3 bytes null
    * 1 byte type: 01
    * subrecord: CPU output status in STOP mode
      * 2 bytes length
        * 08 00: xx20 with 8 outputs \-\> 8 records
        * 0C 00: xx30 with 12 outputs \-\> 16 records (4 unused)
        * 10 00: xx40 with 16 outputs \-\> 16 records
        * 18 00: xx60 with 24 outputs \-\> 24 records
      * n x4 bytes records
        * starting from Q0.0
        * if freeze outputs in last state is enabled, all data here is null
        * 00 00 00 01: output ON in stop mode
        * 00 00 00 00: output OFF in stop mode
    * 2 bytes null
  * signal board
    * 8 bytes
    * \[signal board is described here\]
  * expansion modules
    * 2 bytes: length
      * 06 00 for v2.x
      * 04 00 for v1.x
        * maybe v1.x can only support 4 expansion modules
        * note that v3.x supports 8 expansion modules
    * 2 bytes null
    * n records of 8 bytes each
      * \[each expansion module is described here\]
  * some records
    * R02.04.00.00
      * 2 bytes length: 04 00
      * 4x 8 bytes
      * 2 bytes null
    * R01.00.00.00
      * 2 bytes length: 03 00
      * 3x 8 bytes (null?)
      * 2 bytes null
* timestamps
  * 1 byte version
    * 01: R02.04.00.00
    * 00: R01.00.00.00
  * timestamp 1
  * timestamp 2 \-\> this is updated whenever a symbol table or program block is updated
  * timestamp 3
  * timestamp 4 \-\> this is updated whenever a data page is updated or created (or symbol table is updated/added/removed)
* program blocks
  * 1 byte identifier: 02
  * 2 bytes number of entries: 04 00
  * order of items
    * main program block (OB1)
    * subroutines (SBRx)
    * interrupt routines (INTx)
  * program block
    * 1 byte: program block format version
      * 08: R02.04.00.00
      * 07: R01.00.00.00
    * 2 bytes type
      * main block: E8 03 (1000)
      * subroutine: E9 03 (1001)
      * interrupt routine: EA 03 (1002)
    * 2 bytes null
    * 2 bytes program block index
      * main: 00 00 (always OB1)
      * subroutine: SBRx (0-based)
      * interrupt: INTx (0-based)
    * 2 bytes type: 01 00
    * 18 bytes null
    * 4 bytes parameters
      * only on R02.04.00.00
      * missing on R01.00.00.00
      * editor open: 01 00 00 00
      * editor closed: 00 00 00 00
      * main block is always open
    * 2 bytes version
      * 0D 00: R02.04.00.00
      * 0B 00: R01.00.00.00
    * program block name
      * 2 bytes length
      * n bytes string contents
    * 1 byte null
    * program block comment
      * 2 bytes length
      * n bytes string contents
      * only on R01.00.00.00
      * always zero length on R02.04.00.00
    * 1 byte null
    * program block info
      * R02.04.00.00
        * author name
          * 2 bytes length
          * n bytes string contents
        * 42 bytes null
        * 44 bytes
          * option 1 (sometimes for MAIN)
            * 30 bytes data
            * 4 bytes null
            * 10 bytes data
          * option 2 (sometimes for MAIN)
            * 44 bytes null
          * option 3 (for SBR or INT)
            * 6 bytes null
            * 16 bytes data
            * 4 bytes null
            * 14 bytes data
            * 4 bytes null
        * 3 bytes null
      * R01.00.00.00
        * 27 bytes unknown (null?)
    * timestamp created time (localtime)
    * timestamp last modified time (updated whenever symbol table or program block is updated)
    * 1 byte null
    * array
      * 2 bytes number of networks
      * networks (repeated for each network)
        * 2 bytes network index
        * 4 bytes 02 01 04 00 \= 262402
        * network title
          * 2 bytes length
            * always 0 on R02.04.00.00
          * n bytes network title
        * 1 byte null
        * network comment
          * 2 bytes length
          * n bytes comment string
        * xx bytes network data
          * \[each network's program contents are described here\]
    * 1 byte null
    * symbol table for program block
      * 2 bytes number of entries
      * \[each entry is described here\]
    * 4 bytes null
    * 4 bytes: 01 00 00 00
    * 4 bytes: 64 00 00 00
* symbol tables
  * 1 byte version
    * 06: R02.04.00.00
    * 05: R01.00.00.00
  * 2 bytes number of entries: 04 00
  * symbol table
    * 1 byte version
      * 08: R02.04.00.00
      * 07: R01.00.00.00
    * 2 bytes
      * symbol table: B8 0B (3000)
      * POU Symbols: B9 0B (3001)
    * 2 bytes zero bytes
    * 2 bytes symbol table index (0-based)
      * restart from 0 for POU Symbols
      * it's like POU Symbols have its own list
      * but the lists are merged in the editor
    * 2 bytes: type
      * symbol table: 01 00
      * POU Symbols
        * 80 00: R02.04.00.00
        * 08 00: R01.00.00.00
    * null bytes
      * 22 bytes null: R02.04.00.00
      * 18 bytes null: R01.00.00.00
    * 2 bytes: 02 00
    * symbol table name
      * 2 bytes length
      * n bytes symbol table name
    * 18 bytes zero bytes
    * 4 bytes FF FF FF FF
    * 2 bytes number of entries
    * \[each symbol table entry is described here\]
* status charts
  * 1 byte identifier: 03
  * 4 bytes: 01 00 00 00
  * 2 bytes number of status charts: 05 00
  * 1 byte version
    * 08: R02.04.00.00
    * 07: R01.00.00.00
  * 2 bytes: A0 0F (4000)
  * 2 bytes null
  * status chart
    * 2 bytes status chart index (0-based)
    * 2 bytes type: 01 00
    * null bytes
      * 22 bytes null: R02.04.00.00
      * 18 bytes null: R01.00.00.00
    * 2 bytes: 02 00
    * status chart name
      * 2 bytes length
      * n bytes string contents
    * 8 bytes null
    * 2 bytes number of entries
    * status chart entry
      * status chart entry index (0-based)
      * 4 bytes: 01 02 03 01
      * 2 bytes: 02 00
      * 2 bytes null
      * ...
* data pages
  * 1 byte identifier: 02
  * 2 bytes number of data pages
  * data page
    * when data pages are added, some timestamps are updated
    * each individual data page has its own timestamps (created time and last modified time), find them
    * 1 byte version
      * 08: R02.04.00.00
      * 07: R01.00.00.00
    * 2 bytes: 88 13 (5000)
    * 2 bytes null
    * 2 bytes data page index (0-based)
    * 2 bytes type: 01 00
    * null bytes
      * 22 bytes null: R02.04.00.00
      * 18 bytes null: R01.00.00.00
    * 2 bytes version
      * 05 00: R02.04.00.00
      * 03 00: R01.00.00.00
    * data page name
      * 2 bytes length
      * n bytes string contents
    * 4 bytes null
    * data page author
      * 2 bytes length
      * n bytes string
      * can be zero length
    *
    * 42 bytes null
    * 44 bytes unknown
    * 2 bytes number of data page entries
    * data page entries
      * 2 bytes data page entry index
      * 2 bytes:
        * empty: 02 00
        * normal assignment: 02 01
        * assignment for undefined memory type: 02 02
      * 4 bytes null
        * invalid string: D4 0A 00 A0 for "1/world"
      * 4 bytes: 01 00 00 00
      * 4 bytes null
      * 1 byte null
      * 2 bytes: 01 01
      * 2 bytes number of items/elements on the line
      * variable (only if number of items is not zero)
        * 2 bytes index: 00
          * index always 0 for variable
        * 1 byte 01
        * 4 bytes: 03 01 00 00
        * 2 bytes null
        * 1 byte: 01
        * 4 bytes: 00 00 00 00 \-\> string offset from start of line
        * 4 bytes: 02 00 02 10 \-\> data type of value
          * 02: VB
          * 04: VW
          * 08: VD
          * 40: Vx undefined memory type
        * 3 bytes null
        * 4 bytes: 02 00 00 00 \-\> variable offset
          * it was 4D 01 00 00 when an entry is invalid
      * values (only if number of items is not zero)
        * 2 bytes index (starts from 1\)
          * because variable is at 0th index
        * 1 byte: 00
          * got 02 for invalid line like "1/world"
        * 4 bytes: 03 01 00 00
          * got "03 01 01 00" for "1/world"
        * 2 bytes null
        * 1 byte 01
        * 4 bytes: 0C 00 00 00 \-\> value string offset from start of line, but not reliable
        * 4 bytes: 01 01 02 01 \-\> data type of value
          * 01 01 02 01: byte
          * 01 01 04 01: word
          * 01 01 08 01: dword or dint
          * 01 04 02 01: hex 2 chars
          * 01 04 04 01: hex 4 chars
          * 01 05 02 01: binary 2 bits
          * 01 06 10 01: ascii
          * 01 07 08 01: real
          * 01 08 10 01: string
          * 01 00 01 00: for invalid line "1/world" for items 2 & 3
        * 4 bytes: FB 00 00 00 \-\> value
          * if ascii string, this value is null
          * if invalid, this value is missing
        * ascii string or regular string
          * 1 byte length \-\> can be zero
          * n bytes ascii string
    * 1 byte null
    * 2 bytes: number of data page entries
    * data page entries (aux data)
      * 2 bytes data page line index (0-based)
      * 2 bytes:
        * comment only: 02 01
        * normal: 02 07
        * normal with comment: 02 02
        * empty is the same as normal
        * space is the same as normal
        * invalid is the same as normal
      * 2 bytes: unknown
        * sometimes null
        * sometimes F0 43
        * sometimes B0 1B
        * sometimes 00 44
        * sometimes 3B 63
        * sometimes 03 00
        * sometimes 05 00
        * sometimes 08 00
        * sometimes 09 00
        * sometimes 10 00
        * sometimes 23 00
        * sometimes 0A 00
        * if there is data, then this is line length (length of data)
          * length includes textual representation including comments, if any
          * if there is a comment, this number is incremented by 1
          * sometimes line length minus 1
          * this might be something else
      * 2 bytes unknown
        * sometimes null
        * sometimes 99 02
        * sometimes 21 73
        * sometimes 1F 73
        * sometimes B2 6B
      * 1 byte null
      * line comment
        * 2 bytes length
        * n bytes string
        * trailing spaces are encoded as-is
        * trailing null is not present
        * can be zero-length
    * 2 bytes null
* 1 byte null
* CPU configuration
  * CPU type string
    * 2 bytes length: 08 00
    * n bytes string contents "CPU SR20" or some other string
  * 1 byte null
  * CPU version string
    * 2 bytes length: 15 00
    * n bytes string contents
  * CPU information block
    * 2 bytes length: D4 00
    * n bytes contents
    * contents
      * 17 bytes: "CPU SR20        V"
      * 7 bytes CPU firmware version
        * 02 08 02 00 00 00 00 for V02.08.02\_00.00.00.00
        * 02 08 00 00 00 00 00 for V02.08.00\_00.00.00.00
        * 02 07 00 00 01 00 00 for V02.07.00\_00.00.00.00
        * 02 05 01 00 01 00 00 for V02.05.01\_00.00.01.00
        * 02 05 00 00 07 00 00 for V02.05.00\_00.00.07.00
        * 02 04 01 00 03 00 00 for V02.04.01\_00.00.03.00
        * 02 01 00 00 03 00 00 for V02.01.00\_00.00.03.00
        * 01 00 02 00 00 00 00 for V01.00.02\_00.00.00.00
        * 01 00 00 00 01 00 00 for V01.00.00\_00.00.01.00
        * 01 00 00 00 00 00 00 for V01.00.00\_00.00.00.00
      * 6 bytes unknown: 00 22 00 43 03 FC
      * 6 bytes unknown
        * 00 22 00 43 03 FC for ST SR
          * same as previous 6 bytes
        * 00 00 00 00 00 00 for CR..s
      * 2 bytes
        * 28 00 for v2.8 v2.7 v2.6 v2.5
        * 24 00 for v2.4
        * 01 00 for v2.3 v2.2 v2.0 v1.x
      * 4 bytes
        * 00 0E 00 0E SR60 CR60s CR40s CR30s
        * 00 0C 00 0C CR20s
      * 2 bytes
        * 28 00 for v2.8 v2.7 v2.6 v2.5
        * 24 00 for v2.4
        * 01 00 for v2.3 v2.2 v2.1 v2.0 v1.x
      * 2 bytes unknown: 01 00
      * 2 bytes unknown
        * 40 00 for v2.8 v2.7 v2.6 v2.5 v2.4 v2.3 v2.2 v2.1
        * 30 00 for v2.0 v1.x
      * 2 bytes unknown: 01 00
      * 4 bytes
        * 28 00 28 00 for SR60 v2.8
        * 18 00 18 00 for v2.8
        * 10 00 10 00 for v2.7 v2.6 v2.5 v2.4 v2.3 v2.2 v2.1 v2.0 v1.x
      * 4 bytes
        * 01 00 01 00 for v2.8 v2.7 v2.6 v2.5 v2.2 v2.0 v1.x
        * 00 00 00 00 for v2.4 v2.3
      * 8 bytes unknown
        * 06 DB 00 01
        * 06 DB 00 01
        * 4 bytes repeated twice
      * 4 bytes unknown
        * 06 DB 06 DB for v2.8 v2.7 v2.6 v2.5 v2.4 v2.3
        * 00 00 00 00 for v2.2 v2.1 v2.0 v1.x
        * 00 00 00 00 for CR..s v2.3
      * 8 bytes null
      * 4 bytes
        * 00 38 00 38 for SR60
        * 00 00 00 00 for CR60s
      * 4 bytes: 00 20 03 00
      * 2 bytes
        * 3C 00 for SR60
        * 30 00 for ST40 v1.x
        * 18 00 for CR60s
      * 4 bytes null
      * 4 bytes
        * 00 C8 03 E8 for v2.x
        * 00 64 01 F4 for v1.x
      * 6 bytes: 00 01 00 80 00 80
      * 6 bytes unknown (bitfield)
        * 3F FF FF FF 18 7B for SR60 SR40 v2.8 v2.7 v2.6 v2.5 v2.4 v2.3
          * 18 7F for ST60 ST40
        * 3F FF 1F FF 00 79 for v2.2 v2.1 v2.0 v1.x
        * 3F FF 1F FF 00 7D for ST40 v1.x
        * 3F FF 18 E7 00 01 for CR..s (v2.3 only)
      * 4 bytes unknown: 00 00 04 00
      * 2 bytes unknown, related to model
        * 00 02 for ST60
        * 00 00 for SR60
        * 00 01 for ST40 ST30 ST20
        * 00 00 for SR40 SR30 SR20 and ST40v1.x
        * 00 00 for CR..s
      * 2 bytes: 01 00
      * 2 bytes unknown, related to version
        * 00 10 for v2.8
        * 00 08 for v2.7 v2.6 v2.5 v2.4 v2.3 v2.2 v2.1 v2.0 v1.x
      * 1 byte null
      * 1 byte: number of expansion modules supported?
        * 06 for ST SR v2.x
        * 04 for ST SR v1.x
        * 00 for CR60s
      * 4 bytes
        * 00 00 00 03 for SR60 ST40v1.x
        * 00 00 00 04 for ST60
        * 00 00 00 00 for CR60s
      * 6 bytes unknown
      * 2 bytes
        * 01 01 v2.8 v2.7 v2.6 v2.5
        * 00 00 v2.4 v2.3 v2.2 v2.1 v2.0 v1.x
      * 2 bytes
        * 07 00 for v2.8 v2.7
        * 01 00 for v2.6
        * 00 00 for v2.5 v2.4 v2.3 v2.2 v2.1 v2.0 v1.x
      * 2 bytes: 00 FB
      * 2 bytes some kind of bitfield related to expansion modules
        * 77 0F for v2.x
        * 74 0F for v1.x
      * 2 bytes null
      * 2 bytes
        * 30 00 for ST SR v2.8
        * 28 00 for ST SR v2.7 v2.6 v2.5 v2.4 v2.3
        * 00 00 for ST SR v2.2 v2.1 v2.0 v1.x
        * 08 00 for CR60s v2.3
        * 00 00 for CR60 ST40v1.x
      * 2 bytes
        * 00 00 for v2.x
        * 10 37 for v1.x
      * 18 bytes unknown (bitfield) seems related to CPU features
      * 2 bytes
        * FE F0 for v2.8
        * FE 80 for v2.7 v2.6 v2.5 v2.4 v2.3 v2.2 v2.1 v2.0 v1.x
        * FF 80 for ST40v1.x
      * 14 bytes unknown bitfield
      * 2 bytes
        * 7B FF for CR..s
        * FB FF for CR v2.x
        * 7B FF for CR v1.x ST40v1.x
      * 2 bytes
        * 9F DC for ST SR v2.8 v2.7 v2.6 v2.5 v2.4 v2.3
        * 9F CC for ST SR v2.2 v2.1 v2.0 v1.x
        * 18 0C for CR..s
        * 9F CC for CR v2.x
        * 0F EC for CR v1.x ST40v1.x
      * 6 bytes
        * FF FF FF FF 1F FF for v2.8
        * 00 FF 00 00 00 00 for v2.7 v2.6 v2.5 v2.4
        * 00 0F 00 00 00 00 for v2.3 v2.2
        * 00 00 00 00 00 00 for v2.1 v2.0 v1.x
        * 00 00 00 00 00 00 for CR60s
        * 00 0F 00 00 00 00 for CR v2.2
        * 00 00 00 00 00 00 for CR v2.1 ST40v1.x
      * 24 bytes unknown
        * 6 bytes null
        * 1 byte number of cpu inputs
        * 1 byte number of cpu outputs
        * 2 bytes null
        * 2 bytes
          * 3C 00 for SR60
          * 18 00 for CR60s CR40s
          * 30 00 for ST40v1.x
        * 6 bytes null
        * 4 bytes
          * 00 04 00 CB for SR60
          * 00 00 00 00 for CR60s
          * 00 04 00 CB for CR v2.x
          * 00 00 00 00 for CR v1.x ST40v1.x
        * 2 bytes: 00 C8
* 2 bytes null
* project name string
  * 2 bytes length (sometimes 00 00\)
  * n bytes string
*
* TODO below:
* unknown bytes ...
  * not sure how they are encoded
* library subroutines? or built-in tables? or maybe wizard data?
  * PID 0...15 are mentioned
  * PG 1..3 INIT are mentioned (specific to winder project)
  * EXTERN\_RESET
  * DIR\_CHANGE
  * COUNT\_EQ
  * are mentioned, seems related to HSC

## signal board

* if not present: 8 bytes null
* if SB DT04
  * 8 bytes: 00 20 00 80 01 00 00 00
  * 1 byte 06
  * 32 bytes unknown
    * 4 bytes 01 00 00 00
    * 4 bytes 07 00 00 00
      * input start offset?
    * 4 bytes 07 00 00 00
      * output start offset?
    * 20 bytes null
  * 8 bytes: 00 20 00 80 02 00 00 00
  * 4 bytes null
  * 6 bytes: 00 02 01 00 00 00
  * 1 byte null
  * signal board info
    * 1 byte 02
    * 2 bytes length: 02 00
    * 2 bytes null
    * n x2 bytes input config
      * starting from I7.0
      * same as cpu input config
    * 4 bytes: 01 00 00 00
    * 1 byte null
    * 1 byte 01
    * 2 bytes length
    * 2 bytes null
    * n x4 bytes output config
      * starting from Q7.0
      * same as cpu output config
  * 6 bytes null
  * 18 bytes null
  * 8 bytes unknown: 02 02 00 00 00 01 00 00
  * 10 bytes null
  * 8 bytes unknown: 01 00 00 00 01 00 00 00
* if SB AE01
  * 8 bytes: 11 20 00 80 01 00 00 00
  * 1 byte 06
  * 32 bytes unknown
    * 4 bytes 01 00 00 00
    * 4 bytes 0C 00 0E 00 (input start offset and type?)
    * 4 bytes 0C 00 0E 00 (output start offset and type? but nonexistent on this module)
    * 20 bytes null
  * 8 bytes: 11 20 00 80 02 00 00 00
  * 4 bytes null
  * 6 bytes: 00 02 01 00 00 00
  * 2 bytes null
  * signal board info
    * 1 byte 01
    * 2 bytes length: 01 00
    * 2 bytes null
    * 8 bytes info for AIW12 (only one)
      * input type
        * 01 09: voltage \+/- 10v
        * 01 08: voltage \+/- 5v
        * 01 07: voltage \+/- 2.5v
        * 03 02: current 0-20 ma
      * 1 byte null
      * 1 byte rejection & smoothing
        * bits 7-4: rejection
        * 3: 10 Hz
        * 2: 50 Hz
        * 1: 60 Hz
        * 0: 400 Hz
        * bits 3-0: smoothing
        * \-- 0: none
        * \-- 1: weak (4 cycles)
        * \-- 2: medium (16 cycles)
        * \-- 3: strong (32 cycles)
      * 00 00
      * 1 byte alarms (bitfield)
        * bit 7: upper
        * bit 6: lower
        * bits 5-0: unused
      * 1 byte null
  * 18 bytes null
  * 8 bytes unknown: 02 02 00 00 00 01 00 00
  * 10 bytes null
  * 8 bytes unknown: 01 00 00 00 01 00 00 00
* if SB AQ01
  * 8 bytes: 10 20 00 80 01 00 00 00
  * 1 byte 06
  * 32 bytes unknown
    * 4 bytes 01 00 00 00
    * 4 bytes 0C 00 0E 00 (input start offset and type?)
    * 4 bytes 0C 00 0E 00 (output start offset and type? but nonexistent on this module)
    * 20 bytes null
  * 8 bytes: 10 20 00 80 02 00 00 00
  * 4 bytes null
  * 6 bytes: 00 02 01 00 00 00
    * freeze output: 00 02 01 01 00 00
  * 2 bytes null
  * signal board info
    * 1 byte 01
    * 2 bytes length: 01 00
    * 2 bytes null
    * 8 bytes info for AQW12 (only one)
      * 2 bytes output type
        * 01 00: voltage \+/- 10v
        * 03 01: current 0-20 ma
      * 1 byte null
      * 1 byte alarms (bitfield)
        * bit 7: upper
        * bit 6: lower
        * bit 5: unused
        * bit 4: wire break
        * bit 3: unused
        * bit 2: short circuit
        * bit 1: unused
        * bit 0: unused
      * 1 byte output config
        * no freeze output: 30
        * freeze output: 20
      * 2 bytes substitute value
      * 01 00
  * 2 bytes null
  * 8 bytes unknown: 02 02 00 00 00 01 00 00
  * 10 bytes null
  * 8 bytes unknown: 01 00 00 00 01 00 00 00
* if SB BA01
  * 8 bytes: 1D 20 00 80 01 00 00 00
  * 1 byte 06
  * 32 bytes unknown
    * 4 bytes 01 00 00 00
    * 4 bytes 07 00 00 00 (signal offset?)
    * 4 bytes 07 00 00 00 (signal offset?)
    * 12 bytes null
    * 4 bytes: 01 00 00 00
    * 4 bytes null
  * 8 bytes: 1D 20 00 80 02 00 00 00
  * 4 bytes null
  * 6 bytes: 00 02 01 00 00 00
    * freeze output: 00 02 01 01 00 00
  * 1 byte null
  * signal board info
    * 1 byte 02
    * 2 bytes length: 01 00
    * 2 bytes null
    * 8 bytes info for AQW12 (only one)
      * 00 07
      * 02 02
      * 00 00
      * 00 01
  * 2 bytes null
  * 8 bytes unknown: 02 02 00 00 00 01 00 00
  * 10 bytes null
  * 4 bytes: alarm battery low
    * 01 00 00 00: enabled
    * 00 00 00 00: disabled
  * 4 bytes: battery low status as I7.0
    * 01 00 00 00: enabled
    * 00 00 00 00: disabled
* if SB CM01
  * 8 bytes: 1E 20 00 80 01 00 00 00
  * 1 byte 06
  * 32 bytes unknown
    * 4 bytes 01 00 00 00
    * 16 bytes null
    * 4 bytes: 01 00 00 00
    * 8 bytes null
  * 8 bytes: 1E 20 00 80 02 00 00 00
  * 4 bytes null
  * 6 bytes: 00 02 02 02 00 00
    * 3 bytes: 00 02 02
    * 1 byte: Modbus station address
    * 2 bytes: 00 00
  * 1 byte null
  * 1 byte: baud rate
    * 01: 9600
    * 02: 19200
    * 04: 187500
  * 6 bytes null
  * 2 bytes type
    * 00 00: RS385
    * 00 01: RS232
  * 12 bytes null

## expansion modules

* if empty record
  * 8 bytes null
* if DP01: 293 bytes
  * 4 bytes: 01 40 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> offset
  * 4 bytes: 08 00 00 \-\> offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes: 01 00 00 00
  * 4 bytes: 01 40 00 80
  * 2 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 02
  * array
    * 2 bytes length: 20 00
    * 2 bytes null
    * 32 x2 bytes: digital input config??
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 20 00
    * 2 bytes null
    * 32 x4 bytes null
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if DE08: 39 bytes
  * 4 bytes: 00 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 00 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 02
  * array
    * 2 bytes length: 08 00
    * 2 bytes null
    * 8 x2 bytes: digital input config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if DE16: 39 bytes
  * 4 bytes: 16 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 16 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 02
  * array
    * 2 bytes length: 10 00
    * 2 bytes null
    * 16 x2 bytes: digital input config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if DT08: 39 bytes
  * 4 bytes: 01 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 01 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 08 00
    * 2 bytes null
    * 8 x4 bytes: null, maybe output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if DR08: 39 bytes
  * 4 bytes: 02 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 02 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 08 00
    * 2 bytes null
    * 8 x4 bytes: null, maybe output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if QT16: 135 bytes
  * 4 bytes: 17 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 17 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 10 00
    * 2 bytes null
    * 16 x4 bytes: null, maybe output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if QR16: 135 bytes
  * 4 bytes: 18 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 18 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 10 00
    * 2 bytes null
    * 16 x4 bytes: null, maybe output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if DT16: 129 bytes
  * 4 bytes: 03 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 03 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 02
  * array
    * 2 bytes length: 08 00
    * 2 bytes null
    * 8 x2 bytes: input config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 08 00
    * 2 bytes null
    * 8 x2 bytes: null, maybe output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if DR16: 129 bytes
  * 4 bytes: 04 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 04 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 02
  * array
    * 2 bytes length: 08 00
    * 2 bytes null
    * 8 x2 bytes: input config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 08 00
    * 2 bytes null
    * 8 x2 bytes: null, maybe output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if DT32: 177 bytes
  * 4 bytes: 05 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 05 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 02
  * array
    * 2 bytes length: 10 00
    * 2 bytes null
    * 16 x2 bytes: input config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 10 00
    * 2 bytes null
    * 16 x4 bytes: null, maybe output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if DR32: 177 bytes
  * 4 bytes: 06 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 08 00 00 \-\> input image offset
  * 4 bytes: 08 00 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 06 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 02
  * array
    * 2 bytes length: 10 00
    * 2 bytes null
    * 16 x2 bytes: input config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 10 00
    * 2 bytes null
    * 16 x4 bytes: null, maybe output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AE04: 176 bytes
  * 4 bytes: 07 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 30 00 3E 00 \-\> input image offset
  * 4 bytes: 30 00 3E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 07 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 04 00
    * 2 bytes null
    * 4 x26 bytes: input config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AE08: 280 bytes
  * 4 bytes: 13 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 40 00 4E 00 \-\> input image offset
  * 4 bytes: 40 00 4E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 13 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 08 00
    * 2 bytes null
    * 8 x26 bytes: input config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AQ02: 40 bytes
  * 4 bytes: 08 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 50 00 5E 00 \-\> input image offset
  * 4 bytes: 50 00 5E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 08 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 02 00
    * 2 bytes null
    * 2 x6 bytes: output config
  * 4 bytes: 02 00 00 00
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AQ04: 52 bytes
  * 4 bytes: 15 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 60 00 6E 00 \-\> input image offset
  * 4 bytes: 60 00 6E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 15 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 04 00
    * 2 bytes null
    * 4 x6 bytes: output config
  * 4 bytes: 04 00 00 00
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AM03: 145 bytes
  * 4 bytes: 12 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 10 00 1E 00 \-\> input image offset
  * 4 bytes: 10 00 1E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 12 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 02 00
    * 2 bytes null
    * 2 x26 bytes: output config
      * user power alarm is encoded as a bit in each channel here
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 01 00
    * 2 bytes null
    * 1 x6 bytes: output config
      * user power alarm is also encoded as a bit in each channel here
  * 4 bytes: 01 00 00 00
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AM06: 203 bytes
  * 4 bytes: 09 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 20 00 2E 00 \-\> input image offset
  * 4 bytes: 20 00 2E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 09 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 04 00
    * 2 bytes null
    * 4 x26 bytes: output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 02 00
    * 2 bytes null
    * 2 x6 bytes: output config
  * 4 bytes: 02 00 00 00
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AR02: 124 bytes
  * 4 bytes: 10 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 50 00 5E 00 \-\> input image offset
  * 4 bytes: 50 00 5E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 10 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 02 00
    * 2 bytes null
    * 2 x26 bytes: output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AR04: 176 bytes
  * 4 bytes: 14 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 50 00 5E 00 \-\> input image offset
  * 4 bytes: 50 00 5E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 14 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 01
  * array
    * 2 bytes length: 04 00
    * 2 bytes null
    * 2 x26 bytes: output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if AT04: 176 bytes
  * 4 bytes: 11 30 00 80
  * 4 bytes: 01 00 00 00
  * 1 byte: 06
  * 4 bytes: 01 00 00 00
  * 4 bytes: 50 00 5E 00 \-\> input image offset
  * 4 bytes: 50 00 5E 00 \-\> output image offset
  * 4 bytes null
  * 4 bytes EM number
  * 8 bytes null
  * 4 bytes null
  * 4 bytes: 11 30 00 80
  * 4 bytes: 03 00 00 00
  * 4 bytes: EM number
  * 2 bytes: 00 03
  * 4 bytes: 01 00 00 00
  * 1 byte null
  * 2 bytes: 00 00
  * array
    * 2 bytes length: 04 00
    * 2 bytes null
    * 2 x26 bytes: output config
  * 4 bytes: 01 00 00 00
  * 2 bytes: 00 01
* if leftover data
  * 4 bytes: previous marker
    * 01 40 00 80
    * 00 30 00 80
  * 4 bytes: null

## network

### network content

* the ladder network is described in terms of elements / blocks
* each network can have a maximum of 32 lines (rows) and 32 items per line (columns)
* each element in each network has a line number & column number
* even connecting lines are described as an element
* dangling arrows are also described as an element
* any element that can be visually added in the program editor is described as an element
* ~~vertical connection is "owned" by the lower line~~
* for connecting lines, an element describes
  * horizontal line in the middle
  * vertical line going up on the right side
  * vertical line going down on the right side

the basic format of a network description is as follows

* 4 bytes 01 00 00 00
* 2 bytes null
* 4 bytes 02 00 00 00
* 4 bytes
  * 00 00 00 00: no bookmark
  * 01 00 00 00: bookmark
* 2 bytes 00 01
* 2 bytes: number of elements in the network
* element 0
* element 1
* ...
* last element

#### network element

the basic format of a network element is as follows

* 1 byte null
* 1 byte line number
* 1 byte column number
* 1 byte: 03
* 4 bytes: type
  * 01 00 00 00: dangling arrow, vertical line, final arrow
  * 01 01 00 00: horizontal line
  * 01 14 00 00: NO contact
  * 01 15 00 00: NC contact
  * 01 18 00 00: NOT
  * 01 19 00 00: positive transition
  * 01 1A 00 00: negative transition
  * 01 1B 00 00: output coil
  * 01 20 00 00: reset coil
  * 01 23 00 00: NOP box
  * 01 1D 00 00: set coil
  * 01 4A 01 00: ADD\_R box
  * 01 49 01 00: LPF box
  * 01 59 01 00: ADD\_I box
  * 01 A0 00 00: XMT box
  * 01 A0 01 00: MOV\_W
  * 01 E9 03 00: subroutine \#0
  * 01 E9 03 01: subroutine \#1
* 4 bytes
  * byte 0: type
    * 07: final arrow
    * 06: dangling arrow
    * 05: horizontal line
    * 03: contact
    * 04: coil (output)
    * 02: second half of box
      * maybe: box or part of box, with call parameters
    * 01: subroutine or box or top of box
      * maybe: box or part of box, with lines coming in or out
  * byte 1: lines on the right side
    * 03: going up and going down
    * 02: going down
    * 01: going up
    * 00: none
  * byte 2:
    * 00: usually, unknown, second half of box
    * 05: NOP box
    * 02: subroutine or top of box
  * byte 3
    * 00: usually, unknown, top half of box
    * 09: NOP box, second half of LPF box, subroutine
    * 06: second half of ADD\_I ADD\_R XMT box
    * 03: second half of MOV\_W box
    * maybe: 03 means 1 row, 06 means 2 rows, 09 means 3 rows
      * which means one row is divided into 3 columns
  * examples
    * 07 00 00 00: final arrow
    * 06 00 00 00: dangling arrow
    * 05 00 00 00: horizontal line only
    * 00 03 00 00: vertical line going up and going down on the right side
    * 05 02 00 00: horizontal line with vertical line going down on the right side
    * 03 00 00 00: normal contact or coil?
    * h04 00 00 00: output coil (set coil, reset coil)
* 1 byte:
  * number of data records following
  * 03: usually, box, but subroutine with multiple inputs also 03
    * 3x (null+24+2+24+2+null+24+2+24+2+null+24+2+24+2)
    * 24 bytes of data is text padded with zeros
      * max length is 23, so there is always a trailing null
    * 2 bytes of data is status
      * 01 00 data absent / empty
      * 02 02 data present / filled
    * for single row box or first row of box, the first record contains the box title, stored in the first 24, and the second 24 is empty
      * the second part contains EN (always) and ENO (if not subroutine or NOP)
    * for subsequent rows of box, the first record contains labels (parameters) from the first line (left and then right), and so on
    * for contact with label (even NO contact has " " as label), it is stored on the second record, the first 24
  * 00: final arrow, no data records
* records (if number of data records is not 0\)
  * usually 03
    * the only time it's not 03 seems to be in an empty network with a single end arrow
  * 1 byte null
  * 24 bytes: box label padded with nulls, or first row left side entry
    * usually null
    * ADD\_I then null: ADD\_I box top
    * ADD\_R then null: ADD\_R box top
    * XMT then null: XMT box top
    * IN1 then null: ADD\_I ADD\_R box second half
    * TBL then null: XMT box second half
    * MOV\_W then null: MOV\_W box top
    * IN then null: MOV\_W LPF box second half
    * LPF then null: LPF box top
    * SBR\_0: SBR\_0 box
    * SBR\_1: SBR\_1 box
    * in0002: SBR\_0 third part
  * 2 bytes
    * 01 00: usually, box top or subroutine
    * 00 02: ADD\_I ADD\_R MOV\_W LPF box second half, SBR\_0 third part
  * 24 bytes
    * usually null, box half or subroutine
    * OUT then null: ADD\_I ADD\_R MOV\_W LPF box second half
    * out001: SBR\_0 third part
  * 2 bytes
    * 01 00 usually, box top half, subroutine, XMT box second half
    * 02 02: ADD\_I ADD\_R MOV\_W LPF box second half, SBR\_0 third part
  * 1 byte null
  * 24 bytes: element data? or label? or second line of box?
    * 00 00 00 00 ... unknown but this is the usual value, also MOV\_W box second half
    * ' ' 00 00 00 ... NO contact, output coil
      * NO contact has a space in the middle
    * '/' 00 00 00 ... NC contact
      * NC contact has a space in the middle
    * 'N' 00 00 00 ... negative transition
    * 'P' 00 00 00 ... positive transition
    * 'R' 00 00 00 ... reset coil
    * 'S' 00 00 00 ... set coil
    * 'N' 'O' 'T' 00 00 00 ... NOT
    * 'N' 'O' 'P' 00 00 00 ... NOP box
    * 'E' 'N' 00 00 00 ... ADD\_I ADD\_R XMT MOV\_W LPF box top, subroutine \-\> EN input (second line, left side)
    * 'I' 'N' '2' 00 00 00 ... ADD\_I ADD\_R box second half, second line, right side
    * PORT then null: XMT box second half
    * Coef then null: LPF box second half
    * in0003: SBR\_0 third part
  * 2 bytes:
    * 01 00: usually, MOV\_W box second half
    * 01 02: NOP box
    * 00 02: ADD\_I ADD\_R XMT LPF box top half or second half, MOV\_W box top half, subroutine, SBR\_0 third part
  * 24 bytes
    * usually null, box second half, subroutine
    * ENO then null: ADD\_I ADD\_R box top half
      * subroutine doesn't have ENO output
    * "out002": SBR\_0 third part
  * 2 bytes:
    * 01 00: usually, box second half
    * 02 02: box top half, SBR\_0 third part
  * 1 byte null
  * 24 bytes
    * null: usually, or subroutine
    * 00 then N then null: LPF box second half
    * in0004: SBR\_0 third part
  * 2 bytes
    * 00 01: usually, subroutine
    * 00 02: LPF box second half, SBR\_0 third part
  * 24 bytes
    * null usually
    * out003: SBR\_0 third part
  * 2 bytes?
    * 01 00: usually
    * 02 02: SBR\_0 third part
* 2 bytes: 01 01
* array: values to give to the element, only found at the first part if a box
  * 2 bytes: number of records
  * n records
    * example indexes for: ADD\_I 12 \+ 25 \= VW15 (0c 19 0f)
      * FF FF
      * 01 00
      * 02 00
      * FF FF
      * 04 00
      * maybe: the first FF is for EN, the second FF is for ENO
      * maybe FF means horizontal line in this case
      * but look at XMT
    * example indexes for: XMT IN \+ IN, no out
      * FF FF
      * 01 00
      * 02 00
      * maybe FF means start of section (IN, IN\_OUT, OUT)
    * example indexes for: MOV\_W IN OUT
      * FF FF
      * 01 00
      * FF FF
      * 03 00
    * example indexes for: SBR\_0 EN in\_bit in... in\_out out...
      * FF FF
      * FF FF
      * 02 00
      * ...
      * 10 00
        * maybe FF means horizontal line
        * SBR\_0 has an initial bit input, thus FF FF
        * subroutine doesn't have bit output, thus no third FF FF
    * example: unfilled value (????)
      * 2 bytes: index
      * 01 03
      * 01
      * 02 00 00 00
      * 01
      * 00 00 00 00
      * 02
      * 00 04 10 \-\> box is expecting VW (00 08 10 for VD, 00 02 10 for VB)
        * 00 00
        * 00
        * 00 00 00 00
    * example: \&VB123
      * 2 bytes: index
      * ...
      * 01 02 10 \-\> \&VB
        * 2 bytes 00 00
        * 1 byte nul
        * 4 bytes offset: 7B 00 00 00
    * example: VD16
      * 2 bytes: index
      * 2 bytes: 01 03
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 02
      * 00 08 10 \-\> VD
        * 2 bytes 00 00
        * 1 byte null
        * 4 bytes: 10 00 00 00
    * example: VW15
      * 2 bytes: index
      * 2 bytes: 01 03
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 02
      * 00 04 10 \-\> VW
        * 2 bytes 00 00
        * 1 byte null
        * 4 bytes: 0F 00 00 00
    * example: Always\_On
      * 2 bytes: index
      * 2 bytes: 02 03
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 01
      * 3 bytes: 00 01 00 \-\> string ??
        * 1 byte length: 09
        * n bytes content: Always\_On
        * maximum length seems to be 23 characters
    * example: the number \-13
      * 2 bytes: index
      * 2 bytes: 00 03
      * ...
      * 3 bytes: 02 02 01 \-\> negative byte?
        * 4 bytes: F3 FF FF FF
        * 1 byte null
    * example: the number 5
      * 2 bytes: index
      * 2 bytes: 00 03
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 01
        3 bytes: 01 02 01 \-\> byte
        * 4 bytes: 05 00 00 00 \-\> the number 5
        * 1 byte null
    * example: the number 1
      * 2 bytes: index
      * 2 bytes: 00 03
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 01
      * 4 bytes: 00 00 00 00
      * 1 byte: 01
      * 3 bytes: 01 01 01 \-\> bit (0 and 1 are treated as bit data)
        * 4 bytes: 01 00 00 00 \-\> 1 bit
        * 1 byte null

#### network element examples

* 35 bytes is for empty network
  * 4 bytes 01 00 00 00
  * 2 bytes null
  * 4 bytes 02 00 00 00
  * 4 bytes null
  * 2 bytes 00 01
  * 2 bytes 01 00
    * number of elements in the network
  * element 0: dangling arrow
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte index: 00
    * 1 byte 03
    * 4 bytes 01 00 00 00 \-\> connection?
    * 4 bytes 07 00 00 00 \-\> closed arrow?
    * 3 bytes: 00 01 01
    * 2 bytes null
* 398 bytes: a single Always\_On contact
  * 4 bytes 01 00 00 00
  * 2 bytes null
  * 4 bytes 02 00 00 00
  * 4 bytes null
  * 2 bytes 00 01
  * 4 bytes 02 00
    * number of elements in the network
  * element 0
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte index: 00
    * 1 byte: 03
    * 4 bytes
      * 01 14 00 00: NO contact
      * 01 15 00 00: NC contact
    * 4 bytes: 03 00 00 00
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes
      * 01 00 00 20: NO contact
      * 01 00 00 2F: NC contact
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 byte: 00 00 01 00
    * 4 bytes: 01 01
    * array
      * 2 bytes number of elements: 01 00
      * index: 00 00
      * 2 bytes: 02 03
      * 4 bytes: 01 00 00 00
      * 4 bytes: 00 01 00 00
      * 4 bytes: 00 00 01 00
      * 2 bytes: 01 00 \-\> type??
      * \---string
      * \---1 byte length: 09
      * \---n bytes content: Always\_On
  * element 1: dangling arrow
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte element index in line: 01
    * 1 byte: 03
    * 4 bytes: 01 00 00 00 \-\> arrow?
    * 4 bytes: 06 00 00 00 \-\> connection?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 01 01
    * 2 bytes null
* 32 lines with 32 columns on the first line
  * 4 bytes 01 00 00 00
  * 2 bytes null
  * 4 bytes 02 00 00 00
  * 4 bytes null
  * 2 bytes 00 01
  * 2 bytes 40 00
    * number of elements in the network
    * including dangling arrows
  * element 0: NC contact with value 1
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte index: 00
    * 1 byte: 03
    * 4 bytes
      * 01 14 00 00: NO contact
      * 01 15 00 00: NC contact
    * 4 bytes 03 00 00 00
      * sometimes 03 02 00 00
      * not sure what the meaning is
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes
      * 01 00 00 20: NO contact
      * 01 00 00 2F: NC contact
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 01 00
    * 2 bytes null
    * 4 bytes: 00 03
    * 3 bytes: 01 00 00 00
    * 4 bytes: 00 01 00 00
    * 4 bytes: 00 00 01 01
    * 4 bytes: 01 01 01 00
    * 3 bytes null
  * element 1: horizontal line
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte index: 01
    * 1 byte: 03
    * 4 bytes: 01 01 00 00 \-\> line?
    * 4 bytes: 05 00 00 00 \-\> line?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 00 00
  * element 2: horizontal line
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte element index: 02
    * 1 byte: 03
    * 4 bytes: 01 01 00 00 \-\> line?
    * 4 bytes: 05 00 00 00 \-\> line?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 00 00
  * element 3
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte element index: 03
    * 1 byte: 03
    * 4 bytes: 01 01 00 00 \-\> line?
    * 4 bytes: 05 00 00 00 \-\> line?
      * 05 02 00 00 means there is a line going down
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 00 00
  * element 4: NC contact with value 2
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte index: 04
    * 1 byte: 03
    * 4 bytes
      * 01 14 00 00: NO contact
      * 01 15 00 00: NC contact
    * 4 bytes: 03 00 00 00
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes
      * 01 00 00 20: NO contact
      * 01 00 00 2F: NC contact
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 01 00
    * 2 bytes null
    * 4 bytes: 00 03
    * 3 bytes: 01 00 00 00
    * 4 bytes: 00 01 00 00
    * 4 bytes: 00 00 01 01
    * 4 bytes: 02 01 02 00
    * 3 bytes null
  * ...
  * element 31: 123 R 456
    * 1 byte null
    * 1 byte line number: 00
    * 1 byte index: 1F
    * 1 byte: 03
    * 4 bytes
      * 01 20 00 00: reset coil
      * 01 1D 00 00: set coil
    * 4 bytes: 04 00 00 00 \-\> output coil?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes
      * 01 00 00 52: reset coil
      * 01 00 00 53: set coil
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 2 bytes: 01 01
    * array
      * 2 bytes length: 02 00
      * 2 x24 bytes
        * 2 bytes index: 00 00
        * 4 bytes: 00 03
        * 3 bytes: 01 00 00 00
        * 4 bytes: 00 01 00 00
        * 4 bytes: 00 00 01 07
          * 00 00 01 unknown
          * 07 is real, 01 is whole number
          * 6 bytes: 08 01 7B 00 00 00
          * 02 is ...? byte? not bit? if 01 then bit, if 08 then 32-bit dword or real
          * 01 unknown
          * 7B 00 00 00 \= 123 is the number on top
        * 1 byte null
      * second element
        * 2 byte index: 01 00
        * 2 bytes 00 03
        * 4 bytes: 01 00 00 00
        * 4 bytes: 00 01 00 00
        * 4 bytes: 00 00 01 01
        * 6 bytes: 04 01 C8 01 00 00
          * 04 is word? 08 is dword
          * 01 unknown
          * C8 01 00 00 \= 456 is the number at the bottom
          * D1 2F 01 00 \= 77777
        * 1 byte null
  * element 32: vertical line on right side
    * 1 byte null
    * 1 byte line number: 01
    * 1 byte element index: 00
    * 1 byte: 03
    * 4 bytes: 01 00 00 00 \-\> vertical line?
    * 4 bytes: 00 03 00 00 \-\> vertical line?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 00 00
  * element 33: vertical line on right side
    * 1 byte null
    * 1 byte line number: 02
    * 1 byte element index: 00
    * 1 byte: 03
    * 4 bytes: 01 00 00 00 \-\> vertical line?
    * 4 bytes: 00 03 00 00 \-\> vertical line?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 00 00
  * element 34: vertical line on right side
    * 1 byte null
    * 1 byte line number: 03
    * 1 byte element index: 00
    * 1 byte: 03
    * 4 bytes: 01 00 00 00 \-\> vertical line?
    * 4 bytes: 00 03 00 00 \-\> vertical line?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 00 00
  * element 35: NC contact with value 5
    * 1 byte null
    * 1 byte line number: 04
    * 1 byte index: 00
    * 1 byte: 03
    * 4 bytes
      * 01 14 00 00: NO contact
      * 01 15 00 00: NC contact
    * 4 bytes 03 03 00 00
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes
      * 01 00 00 20: NO contact
      * 01 00 00 2F: NC contact
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 01 00
    * 2 bytes null
    * 4 bytes: 00 03
    * 3 bytes: 01 00 00 00
    * 4 bytes: 00 01 00 00
    * 4 bytes: 00 00 01 01
    * 4 bytes: 02 01 05 00
    * 3 bytes null
  * ...
  * element 62: vertical line on right side
    * 1 byte null
    * 1 byte line number: 1f
    * 1 byte element index: 00
    * 1 byte: 03
    * 4 bytes: 01 00 00 00 \-\> vertical line?
    * 4 bytes: 00 01 00 00 \-\> vertical line on right side but only halfway?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 00 00
  * last element 63: dangling arrow
    * 1 byte null
    * 1 byte line number: 1f
    * 1 byte element index: 01
    * 1 byte: 03
    * 4 bytes: 01 00 00 00 \-\> open arrow?
    * 4 bytes: 06 00 00 00 \-\> connection?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 22 bytes null
    * 4 bytes: 00 00 01 00
    * 4 bytes: 01 01 00 00
* 1 line with 5 contacts & 1 dangling arrow
  * 4 bytes 01 00 00 00
  * 2 bytes null
  * 4 bytes 02 00 00 00
  * 4 bytes null
  * 2 bytes 00 01
  * 4 bytes 06 00 00 00
    * number of elements in the network
    * including dangling arrows
  * element 0
    * 1 byte element index: 00
    * 1 byte 03
    * 4 bytes
      * 01 14 00 00: NO contact
      * 01 15 00 00: NC contact
    * 4 bytes 03 00 00 00
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes
      * 01 00 00 20: NO contact
      * 01 00 00 2F: NC contact
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 01 01
    * 4 bytes: 01 00 00 00
    * 4 bytes: 01 03 01 00
    * 4 bytes: 00 00 00 01
    * 4 bytes null
    * 3 bytes: 02 00 01
    * 4 byes: 10 00 00 00
    * 4 bytes: 0A 00 00 00
      * variable offset
    * 2 bytes null
  * element 1
    * 1 byte element index: 01
    * 1 byte 03
    * 4 bytes
      * 01 14 00 00: NO contact
      * 01 15 00 00: NC contact
    * 4 bytes 03 00 00 00
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes
      * 01 00 00 20: NO contact
      * 01 00 00 2F: NC contact
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 01 01
    * 4 bytes: 01 00 00 00
    * 4 bytes: 01 03 01 00
    * 4 bytes: 00 00 00 01
    * 4 bytes null
    * 3 bytes: 02 00 01
    * 4 byes: 10 00 00 00
    * 4 bytes: 13 00 00 00
      * variable offset
    * 2 bytes null
  * ...
  * last element: dangling arrow
    * 1 byte element index: 05
    * 1 byte: 03
    * 4 bytes: 01 00 00 00 \-\> open arrow?
    * 4 bytes: 06 00 00 00 \-\> connection?
    * 4 bytes: 03 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 00 01 00 00
    * 22 bytes null
    * 4 bytes: 01 00 00 00
    * 22 bytes null
    * 4 bytes: 01 00 01 01
    * 2 bytes null

## symbol table entries

### program block symbol table

symbol table entry (program block)

* 2 bytes: 02 00
* symbol name
  * 2 bytes length
  * n bytes string
* 4 bytes: 00 01 02 00
  * if incomplete: 00 03 00 00
* 2 bytes type
  * EN: 00 00
  * bool: 01 00
  * byte: 02 00
  * word: 04 00
  * int: 04 00
  * dword: 08 00
  * dint: 08 00
  * real: 08 00
  * string: 08 00
  * none if entry incomplete
* 1 byte type
  * EN: 00
  * in/in\_out/out/temp: 20
  * none if entry incomplete
* 2 bytes null
* 2 bytes offset
  * bool: number of bits
  * other: number of bytes
  * present but ignored if entry is invalid
  * none if entry incomplete
* 6 bytes null
  * none if entry incomplete
* 4 bytes type
  * EN: 02 00 00 80
    * any consecutive bool at the top also has this type
  * bool: 02 00 00 00
  * byte: 04 00 04 00
  * word: 48 00 00 00
  * int: 48 00 00 00
  * dword: 90 00 00 00
    * sometimes 10 00 00 00
  * dint: 90 00 00 00
  * real: 00 10 00 00
  * string: 00 00 10 00
  * no type: 00 00 00 00
* 1 byte null
* comment string
  * 2 bytes length
  * n bytes string
* 1 byte: 02
* 1 byte direction/type
  * in: 00
  * in\_out: 01
  * out: 02
  * temp: 03
* 2 bytes: bitfield?
  * in
    * EN: F3 2E
    * bool: F3 2E
    * byte: 33 7E
    * word: F7 7E
    * int: F7 7E
    * dword: F3 FF
    * dint: F3 FF
    * real: F3 7F
    * string: 10 60
  * in\_out
    * bool: F3 2E
    * byte: 33 7E
    * word/int/dword/dint/real: F3 7E
  * out
    * bool: F3 2E
    * byte: 33 7E
    * word/int: FB 7E
    * dword/dint/real: F3 7E
    *
  * temp
    * bool: F3 2E
    * byte: 33 7E
    * word/int/dword/dint/real: F3 7E
  * incomplete: 00 00
* 2 bytes
  * if input and non-bool: 01 00
  * otherwise 00 00
* 1 byte
  * bool: 03
  * byte/word/dword: 01
  * int/dint: 00
  * real: 04
  * string: 06
    * only IN can be string
  * type missing: 09
* 1 byte (bitfield?)
  * EN: 00
  * variable: 01
  * maybe 00 means read-only
  * invalid: 11
    * invalid due to local variable memory not enough
    * can also be due to number of leads not enough (too many local variables)
  * incomplete:
    * no name & no type: 2B
    * name only: 23
    * type only: 29
* 1 byte null

### independent

symbol entries (index is 0-based in file, 1-based in microwin) (independent)

* 2 byte symbol entry index (0-based)
* 2 bytes: 02 00
* symbol name
  * 2 bytes string length
  * n bytes symbol name
  * symbol name can be empty, length will be 00 00
* 4 bytes:
  * looks like a bit field
  * first byte: 00
  * second byte
    * 00 constant
    * 01 memory address
    * 03 incomplete
  * third byte
    * 01 constant
    * 02 memory address
  * fourth byte (looks like enum)
    * 00 memory address
    * 01 positive constant
    * 02 negative constant
    * 03 invalid memory address
    * 04 hexadecimal constant
    * 05 binary constant
    * 06 ascii constant
    * 07 real constant
    * 08 string constant
  * examples
    * no addr: 00 03 00 00
    * name only: 00 03 00 00
    * comment only: 00 03 00 00
* 2 bytes
  * first byte ( data type/size)
    * 01 \= 1 bit / timer / C counter
    * 02 \= 1 byte / AC accumulator
    * 04 \= 2 bytes
    * 08 \= 4 bytes / HC counter / POU / ASCII string
    * 10 \= string
    * 40 \= invalid memory address
  * second byte
    * 00 SM memory / POU / incomplete / invalid memory address / HC counter / AC accumulator / S sequence control relay
    * 01 constant value / I memory
    * 02 Q memory
    * 04 AI memory
    * 08 AQ memory
    * 10 V memory
    * 20 M memory
    * 40 T memory
    * 80 C memory
  * examples
    * MAIN(POU): 08 00
    * Ix.x: 01 01
    * no addr: 00 00
    * name only: 00 00
    * comment only: 00 00
* 2 bytes if memory location:
  * C: 00 00
  * AI: 00 00
  * AQ: 00 00
  * V: 00 00
  * M: 00 00
  * I: 00 00
  * VD: 00 00
  * invalid memory address: 00 00
  * no addr: 00 00
  * HC: 01 00
  * SM: 02 00
  * S: 04 00
  * AC: 10 00
  * MAIN(POU): 00 08
  * byte/int/dint/real const: none
  * name only: none
  * comment only: none
  * string const: none
* 1 byte zero byte if memory location
  * byte/int/dint/real const: none
  * name only: none
  * comment only: none
  * string const: none
  * invalid memory address: none
* 4 bytes data
  * if memory location, then offset
    * number of bits from AA0.0 if bits
    * number of bytes from AA0 if byte / word / dword
    * MAIN(POU): 00 00
  * if const, then value
    * byte const: 4 bytes int value
    * real const: 4 bytes const value
    * dint const: 4 byes const value
    * int const: 4 bytes const value
  * offset is saved even if it's invalid like VD75999
  * name only: none
  * comment only: none
  * string constant: zero bytes
  * invalid memory address: zero bytes
* string constant data
  * 1 byte length (can be 00\)
  * n bytes string constant
* 4 bytes zero bytes
* memory area descriptor
  * 2 bytes
    * looks like an enum or bitfield
    * if offset:
      * MAIN(POU): 00 00
      * bit: 02 00
      * byte: 04 00
      * word: 48 00
      * dword: 90 10
      * timer: 4A 00
    * if const:
      * string const: 00 00
      * negative dint const: 80 00
      * negative int const: C0 00
      * negative byte const: C0 00
      * bit const: DE 00
      * byte const: DC 00
      * small int const: D8 00
      * bin byte const: DC 00
      * hex int const: D8 10
      * int const: 98 00
      * small dint const: 90 00
      * dint const: 10 00
      * 1 byte ascii: 04 00
      * 2 byte ascii: 48 00
      * 4 byte ascii: 90 00
    * name only: none
  * 2 bytes
    * also looks like a bitfield
    * if memory address:
      * bit or timer: 00 60
      * byte: 14 00 or 04 00
      * word: 00 00
      * dword: 00 00
      * MAIN(POU): 02 00
    * if const:
      * negative dint const: 00 00
      * negative int const: 00 00
      * negative byte const: 04 00
      * bit const: 14 or sometimes 04 00
      * byte const: 14 00
      * bin byte const: 04 00
      * hex int const: 00 00
      * small int const: 00 00
      * int const: 00 00
      * small dint const: 00 00
      * dint const: 00 00
      * real const: 10 00
      * string const: 10 00
    * name only: none
* 1 byte zero byte
* comment string
  * 2 bytes string length (can be 0\)
  * n bytes comment
* 2 bytes: 02 00
* string: string entered in address column if invalid
  * 2 bytes length (usually zero)
  * n bytes data
  * usually this column is empty
    * but sometimes the invalid value is not removed
    * resulting in junk data stored here
    * junk data can be inserted here by entering an invalid value as the "address"
    * junk data can be removed by deleting the "address" and entering a valid value
    * simply overwriting the invalid value with a valid value doesn't work \-- we have to clear the field, then enter a valid value \-- seems like an editor quirk
* 2 bytes
  * standard / const / no problem: zero bytes
    * even if memory address is out of range, this value is still zero bytes
  * no name: 08 00 (also for const without name)
  * name only: 20 00
  * comment only: 2A 00
  * invalid or duplicate entry but valid value: 10 00
    * invalid entries can be created by pressing enter on a previous const entry \-- seems like an editor quirk
    * duplicate entries also result in this flag being 10 00
  * invalid const entry with invalid value: 30 00
  * first byte might be a bit field
    * bit 7
    * bit 6
    * bit 5: missing or invalid value entered in address column
    * bit 4: problem related to address column
    * bit 3: symbol name missing (what about invalid name?)
    * bit 2
    * bit 1
    * bit 0

## misc info & notes

integer constants

* x \< \-32768 is negative DINT
* \-32768 \<= x \< \-128 is negative INT
* \-128 \<= x \< 0 is negative BYTE
* 0 \<= x \< 2 is BIT
* 2\<= x \< 128 is positive small BYTE
* 128 \<= x \< 256 is positive BYTE
* 256 \<= x \< 32768 is positive small INT
* 32768 \<= x \< 65536 is positive INT
* 65536 \<= x \< 2147483648 is positive small DINT
* 2147483648 \<= x \< 4294967295 is positive DINT

reverse engineering notes

* usually, strings have 2 byte lengths (without trailing null)
* likewise, records usually have 2 byte lengths
* integers, offsets, values are usually stored as a 32-bit number
* blocks usually have an ending null byte
* index of positive and negative transitions are not stored inside the project file (they are stored in the CPU)
* Symbol Tables have a minimum number of 1
  * POU Symbols can't be edited nor deleted
* Status Charts have a minimum number of 1
* Data Pages have a minimum number of 1

CPU versions

* ST and SR series are the most complete
  * 20 30 40 60
  * v1.x to v2.x
* CR series
  * CR60: v2.0 v2.1 v2.2
  * CR40: v1.x to v2.0 v2.1 v2.2
  * v2.2 has multiple sub-versions: v2.2.0 v2.2.1 v2.2.2 v2.2.3 v2.2.4
    * no discernible differences exist though
* CR..s series
  * 20 30 40 60
  * v2.3 only

network

* max 32 columns
* max 32 rows per network
* values are stored as-is
  * invalid values are stored as-is
  * symbols, like Always\_On for SM0.0 or First\_Scan\_On for SM0.1, are stored as the string itself (not substituted for its memory address)
  * numeric values are stored as-is
* labels are stored in the network data
  * this includes contact labels like NC ('/'), coil labels like reset ('R') and box labels like NOP ('NOP')
* box and subroutine call signature is encoded in the network data
  * this includes input and output parameters
  * including EN and ENO
  * labels are also stored, as above

numeric values

* broadly divided into whole numbers and decimal numbers
* almost always stored as 4 bytes
* whole numbers are further divided into
  * bit: this is 0 or 1
  * byte
  * word / unsigned int
  * int
  * dword / unsigned dint
  * dint
* decimal numbers are stored as a single-precision float value

timestamp is always 16 bytes

* 2 bytes year
* 2 bytes month
* 2 bytes \-- unknown
* 2 bytes day of month
* 2 bytes hour
* 2 bytes minutes
* 2 bytes second
* 2 bytes \-- unknown (maybe milliseconds or parity)

