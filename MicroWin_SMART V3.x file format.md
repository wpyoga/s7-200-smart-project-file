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

Project data is a zip archive. For example, the default template project contains:
- `template\m_mNGMotionCamCfgMap.xml`
- `template\m_mNGMotionAxisCfgMap.xml`
- `template\Data Block\USER1.dbbin`
- `template\m_cSystemBlockData.bin`
- `template\m_mGlbVarTables.xml`
- `template\m_aUdtTable.xml`
- `template\Program Block\MAIN.poubin`
- `template\Program Block\INT_0.poubin`
- `template\Program Block\SBR_0.poubin`
- `template\m_mStatusCharts.xml`
- `template\m_memAllocator.xml`
- `template\m_cUserData.bin`
- `template\template.devproj`
- `template.smartprojs`

`*.xml`, `*.devproj`, and `*.smartprojs` files are XML files. The rest are binary files.

## Notes

- Protection flags `00 03`, `00 04`, ... don't produce any error when the file is opened, but will revert to `00 02` when the file is saved.
  - protection flags `00 00` is invalid
- https://wiki.openssl.org/index.php/EVP_Authenticated_Encryption_and_Decryption
- `7z` unzips the files just fine, although it complains about header errors.
- It seems that the directory entries are Windows paths, thus they have backslashes in them.

