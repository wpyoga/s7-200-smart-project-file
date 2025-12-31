# STEP7-200 Micro/WIN SMART V3 File Format

## Project File Structure

- 256 bytes file header
  - 4 bytes null
  - 12 bytes version string: R03.00.00.00
  - 104 bytes null
  - 2 bytes protection flags
    - 00 02: project is not password protected
    - 00 01: project is password protected
  - 134 bytes null
- encrypted project data
  - project data is a zip file that is then encrypted
  - encrypted using AES-256-GCM
  - encryption key
    - if project is password protected, password is hashed using SHA-256 to generate key
    - if project is not password-protected, a default password "SMART200_V3_PRJ_KEY" is hashed
  - IV and AAD are predefined constants
    - IV: `95 A6 34 68 4A 46 A9 70 EE 90 76 49`
    - AAD: `4A 14 B3 A5 7B C9 F4 92 EB 46 87 94 62 EF B9 C6`
- 16 bytes GCM authentication tag

## Project Data

Project data is a zip archive. For example, the default template project contains files in this order:
- `template\m_mNGMotionCamCfgMap.xml`
- `template\m_mNGMotionAxisCfgMap.xml`
  - motion-control related
- `template\Data Block\USER1.dbbin`
  - data block
  - header: `08 88 13 00`
- `template\m_cSystemBlockData.bin`
  - system block data
  - header: `13 06 00 00`
- `template\m_mGlbVarTables.xml`
  - describes global symbol tables (global variable tables)
- `template\m_aUdtTable.xml`
  - stores UDT tables
- `template\Program Block\MAIN.poubin`
  - these are binary files with XML appended.
  - header: `08 e8 03 00`
- `template\Program Block\INT_0.poubin`
  - these are binary files with XML appended.
  - header: `08 e9 03 00`
- `template\Program Block\SBR_0.poubin`
  - these are binary files with XML appended.
  - header: `08 ea 03 00`
- `template\m_mStatusCharts.xml`
  - describes status charts
- `template\m_memAllocator.xml`
  - not sure what this would/should contain
- `template\m_cUserData.bin`
  - PLC user data, by default it contains only Admin
- `template\template.devproj`
  - main project file
- `template.smartprojs`
  - top-level project XML file

File types:
- `*.xml`, `*.devproj`, and `*.smartprojs` files are XML files.
- `*.dbbin` and `*.bin` files are pure binary files.
- `*.poubin` files are binary files with extra XML data at the end.

## Notes

- Protection flags `00 03`, `00 04`, ... don't produce any error when the file is opened, but will revert to `00 02` when the file is saved.
  - protection flags `00 00` is invalid
- https://wiki.openssl.org/index.php/EVP_Authenticated_Encryption_and_Decryption
- `7z` unzips the files just fine, although it complains about header errors.
- It seems that the directory entries are Windows paths, thus they have backslashes in them.
