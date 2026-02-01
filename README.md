# S7-200 & SMART Project File Format

> Main repository URL: https://github.com/wpyoga/s7-200-smart-project-file
>
> Please post Issues and PRs on the main github repository, or send a message to [wpyoga on 工控人家园论坛](http://www.ymmfa.com/u-gkuid-616507.html) (Chinese BBS site).

[中文](README.zh-Hans.md)

This project aims to reverse engineer the **project file format** for the **S7-200 & SMART series PLCs**.

More specifically, this is the project file format used by **STEP 7-Micro/WIN SMART** (and **STEP 7-Micro/WIN**).

## Goals

Immediate goals:
- Reverse engineer the project file format.
- Make use of Git for project version control:
  - Convert the project file format into JSON or other standard formats.
  - Generate the project file from a JSON file.
  - This should be possible through the use of git commit hooks.
  - Ideally, the generated project file should be byte-identical to the original file.
- Generate a copy-and-paste-able output for Symbol Tables and Data Pages.

Nice-to-have goals:
- Convert program blocks into SCL and vice versa.
- Convert program blocks into AWL.

## Non-goals

We are not trying to:
- Break or circumvent any password protection on a project file.
- Retrieve any password that is used to protect a project file.
- Compete with Siemens in any way, shape, or form.

## File format documentation

- [Micro/WIN SMART V2.x file format](doc/MicroWIN%20SMART%20V2.x%20file%20format.md)
- [Micro/WIN SMART V3.x file format](doc/MicroWIN%20SMART%20V3.x%20file%20format.md)

## Insights

- The SMART V2 project file initially looked like some header + some encrypted binary. In reality, the `0x78 0x9c` bytes were a zlib header.

## Blockers

- I don't have a copy of STEP 7-Micro/WIN SMART v1.0, so I haven't been able to work out
  too many details on the older (oldest) version of the SMART project file format.

## Trivia

- S7-200 SMART is derived from S7-200.
  - The first project file format (that serves as project template, up to v2.8.2.1) even has the version number 4.0.0.46 encoded in it.
- S7-200 SMART was initially developed for emerging markets (China + India). As China (and to a lesser extent, India) export their industrial equipment
  worldwide, the PLC has spread to all corners of the world.
- The initial reverse engineering efforts were based on the French Cafe technique: https://download.samba.org/pub/tridge/misc/french_cafe.txt
- After reverse engineering parts of S7-200 SMART V2 and V3 project files, it was discovered that the older S7-200 file format is incredibly similar
  to that of SMART V2. The preamble section was minimally different, and the Program Block and Symbol Table sections were identical.
