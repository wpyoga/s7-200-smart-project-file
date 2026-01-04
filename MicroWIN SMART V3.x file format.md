# STEP7-200 Micro/WIN SMART V3 File Format

## Project File Structure

- 256 bytes file header
  - 4 bytes null
  - 12 bytes version string:
    - R03.00.00.00
    - R03.01.00.00
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

Project data is a zip archive. For example, the default template project `template.smartv3` contains files in this order:
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
- `template\Program Block\SBR_0.poubin`
- `template\Program Block\INT_0.poubin`
- `template\Program Block\FB_0.poubin`
  - these are binary files with XML embedded
    - in v3.0, the XML is at the end
    - in v3.1, there is additional binary data after the XML
  - header for main program block: `08 e8 03`
    - 08 is the version
    - e8 03 is the main program block marker
  - header for subroutine: `08 e9 03`
    - 08 is the version
    - e9 03 is the subroutine program block marker
  - header for interrupt routine: `08 ea 03`
    - 08 is the version
    - ea 03 is the interrupt routine program block marker
  - header for function block: `08 eb 03`
    - 08 is the version
    - eb 03 is the function block program block marker
- `template\m_mStatusCharts.xml`
  - describes status charts
- `template\m_memAllocator.xml`
  - not sure what this would/should contain
- `template\m_cUserData.bin`
  - PLC user data, by default it contains only Admin
- `template\template.devproj`
  - main project file
  - contains program version that created the file -- maybe we can use this to determine the file header when writing
  - `AllFeatureList` contains a CPU configuration block in Base64
  - DevMode contains all nulls
  - `%[PROJECT]  /  %[OBJECT]` is print header, `%[PAGE]` is print footer
  - each `file` element has a `hashvalue` attribute, and it is the SHA512 checksum of the file, in Base64
- `template.smartprojs`
  - top-level project XML file

File types:
- `*.xml`, `*.devproj`, and `*.smartprojs` files are XML files.
- `*.dbbin` and `*.bin` files are pure binary files.
- `*.poubin` files are binary files with extra XML data at the end.

## Notes

- Protection flags `00 03`, `00 04`, ... don't produce any error when the file is opened, but will revert to `00 02` when the file is saved.
  - protection flags `00 00` is invalid
- Project protection password only externally encrypts the zip archive, and does not affect the zipped data in any way.
- https://wiki.openssl.org/index.php/EVP_Authenticated_Encryption_and_Decryption
- `7z` unzips the files just fine, although it complains about header errors.
- When using `zipdetails` to analyze the archive, note that:
  - Warnings of unexpected padding is misplaced, the supposed padding is the actual compressed data.
- It seems that the directory entries are Windows paths, thus they have backslashes in them.
- When the zip archive contents are extracted, then re-archived and re-integrated into a new project file, it seems to work just fine regardless of:
  - order of files
  - compression level
- Only Store and Deflate compression methods are supported.
- The absolute minimum files that need to be present inside the zip archive are:
  - `template.smartprojs`
  - `template\template.devproj`
- The zip archive was created in a non-compliant way, in which backslashes `\` are used instead of forward slashes `/` as directory separators.
  However, reorganizing the files on Linux using directories and then re-archiving the files works just fine.
- STEP 7-Micro/WIN SMART V3 recognizes the project name from the project file name. Internally stored names are overwritten on save.
  This means that renaming a project file will change its internal name the next time it is saved.
- Within the zip archive, there is a file `<project_name>.smartprojs`. This XML file references a file `<project_name>\<project_name>.devproj`.
  Note the use of backslash as directory separator. This directory separator must always be a backslash -- changing it into a forward slash leads to an error when the file is opened.
- However, the file paths inside `<project_name>\<project_name>.devproj` can be converted into forward slashes and it will not raise an error.
- Each program version (so far) only writes a single file version. For example:
  - V3.0 writes R03.00.00.00
  - V3.1 writes R03.01.00.00
  - V2.7 and V2.8 writes R02.04.00.00
