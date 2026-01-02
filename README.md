# S7-200 SMART Project File Format

This project aims to reverse engineer the project file format for the S7-200 SMART series PLCs.

More specifically, this is the project file format used by STEP7-200 Micro/WIN SMART.

NOTE: Chinese/Mandarin README coming soon

## Goals

Immediate goals:
- Reverse engineer the project file format.
- Convert the project file format into JSON or other standard formats.
- Generate the project file from a JSON file.
- Generate a copy-and-paste-able output for Symbol Tables and Data Pages.
- Make the project file compatible with git for version control.
  - This should be possible through the use of git commit hooks.

Nice-to-have goals:
- Convert program blocks into SCL and vice versa.
- Convert program blocks into AWL.

## Non-goals

We are not trying to:
- Break or circumvent any password protection on a project file.
- Retrieve any password that is used to protect a project file.
- Compete with Siemens in any way, shape, or form.

## File format documentation

- [V2.x](MicroWIN SMART V2.x file format.md)
- [V3.x](MicroWIN SMART V3.x file format.md)

## Insights

- The project file initially looked like some header + some encrypted binary. In reality, the `0x78 0x9c` bytes were a zlib header.

## Blockers

- I don't have a copy of STEP7-200 Micro/WIN SMART v1.0, so I haven't been able to work out
  too many details on the older (oldest) version of the project file format.

## Trivia

- S7-200 SMART is derived from S7-200.
  - The first project file format (that serves as project template, up to v2.8.2.1) even has the version number 4.0.0.46 encoded in it.
- S7-200 SMART was initially developed for emerging markets (China + India). As China (and to a lesser extent, India) export their industrial equipment
  worldwide, the PLC has spread to all corners of the world.
- The initial reverse engineering efforts were based on the French Cafe technique: https://download.samba.org/pub/tridge/misc/french_cafe.txt
