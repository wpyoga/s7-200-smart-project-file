# User List

This is stored inside m_cUserdata.bin, and only present on V3.x

## Description

- 1 byte: 01
- 1 byte: total number of Admin + Maintainer users
- 1 byte: PLC Access Control
  - 00: Disable PLC Access Control
  - 01: Enable PLC Protection (Legacy access control)
  - 02: Enable User Management
- n users (176 bytes each)
  - Admins first, then Maintainers
  - 20 bytes: fixed length user name
  - 12 bytes null
  - 64 bytes: SHA-512 of user password
  - 64 bytes: fixed length user comments / description
  - 1 byte: user category
    - 00: Admin
    - 01: Maintainer
  - 1 byte permission: 07
    - this is a bit field
    - 01: STEP-7 Micro/WIN SMART
    - 02: SMART LINE
    - 04: Web Server
  - 14 bytes null
- 1 bytes: Allow visitor to write user data to PLC
  - 00: do not allow
  - 01: allow
- 1 byte: unknown, sometimes 00, sometimes 01
- 1 bytes: Allow the same user to access PLC from multiple terminals
  - 00: do not allow
  - 01: allow
- 2 bytes: Alive time
- 1 byte: Disallow upload
  - 00: allow upload
  - 01: disallow upload
- 26 bytes null
