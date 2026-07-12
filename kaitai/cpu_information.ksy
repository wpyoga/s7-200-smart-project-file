meta:
  id: cpu_information
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8be33
  # - size: 0xc579
  # - size: 0xb284

  - type: smart_types::null1

  - id: cpu_string
    type: smart_types::strl

  - type: smart_types::null1

  - id: version_string
    type: smart_types::strl

  - id: cpu_features_len
    type: u2

  - id: cpu_features
    type: cpu_features
    size: cpu_features_len
    if: cpu_features_len > 0

  # TODO: figure out the structure
  - type: smart_types::nulls(5)
    if: cpu_features_len == 0


types:
  cpu_features:
    seq:
      - id: cpu_string
        size: 16

      - id: cpu_version
        size: 8

      - id: cpu_family
        size: 6
        # 00 22 00 43 03 fc: ST / SR but also sometimes CR40
        # 00 00 00 00 00 00: CR / CRs

      - id: cpu_family2
        size: 6
        # valid: cpu_family
        # this valid condition is not always met
        # TODO: investigate

      - id: cpu_ver
        type: u2
        # 28 00: v2.5 v2.6 v2.7 v2.8 ST32
        # 24 00: v2.4
        # 01 00: v2.3 v2.2 v2.0 v1.0

      - id: cpu_attr
        type: u2
        # 00 10: ST32
        # 00 0e: SRxx STxx CRxx ... even v1.x
        # 00 0c: CR20s

      - id: cpu_attr_copy
        type: u2
        valid: cpu_attr

      - id: cpu_ver_copy
        type: u2
        valid: cpu_ver

      - id: version_or_num_signal_board
        type: u2
        # maybe number of signal boards?
        # 01 00: v2.x
        # 02 00: v3.x

      - id: sub_version
        type: u2
        # 5d c0: ST32
        # 40 00: v2.8 ~ v2.1
        # 30 00: v2.0

      - type: u2
        valid: 1

      - id: cpu_type
        type: u2
        # c8 00: ST32
        # 28 00: SR60 v2.8
        # 18 00: other v2.8
        # 10 00: v2.7 ~ v2.0, v1.x
        # 20 00: ST40 v1.x (found in template)

      - id: cpu_type_copy
        type: u2
        valid: cpu_type

      - id: cpu_attr2
        type: u2
        # 02 00: ST32
        # 01 00: v2.8 ~ v2.5, v2.2, v2.0, v1.x
        # 00 00: v2.4 v2.3

      - id: cpu_attr2_copy
        type: u2
        valid: cpu_attr2

      - id: cpu_attr3
        type: u4
        # 06 db 00 00: MWP (but the following attrs differ)
        # 06 db 00 01: v2.x v1.x
        # 06 db 06 db: ST32

      - id: cpu_attr3_copy
        type: u4
        valid: cpu_attr3

      - id: cpu_attr4
        type: u2
        # 06 db: ST32
        # 00 00: v2.x v1.x

      - id: cpu_attr4_copy
        type: u2
        valid: cpu_attr4

      - id: cpu_attr5
        type: u2

      - id: cpu_attr5_copy
        type: u2
        valid: cpu_attr5

      - id: cpu_attr6
        type: u2

      - id: cpu_attr6_copy
        type: u2
        valid: cpu_attr6

      - id: cpu_attr7
        type: u2
        # 01 0a: ST32
        # 00 38: ST/SR
        # 00 00: CR/CRs

      - id: cpu_attr7_copy
        type: u2
        valid: cpu_attr7

      - id: cpu_attr8
        type: u4
        # 02 00 09 00: ST32
        # 00 20 03 00: v2.x v1.x

      - id: cpu_attr9
        type: u1
        # c8: ST32
        # 3c: ST60
        # 30: ST40 v1.x
        # 18: CR60s

      - type: smart_types::nulls(6)

      - id: cpu_attr10
        size: 3
        # c8 14 00: ST32
        # c8 03 f8: v2.x
        # 64 01 f4: v1.x-template

      - id: cpu_attr11
        type: u2
        valid: 0x0100

      - id: cpu_attr12
        type: u2
        # 01 00: ST32
        # 00 80: v2.x v1.x

      - id: cpu_attr13
        type: u2
        valid: 0x8000

      - id: cpu_attr14
        size: 8

      - type: u2
        valid: 4

      - id: cpu_attr15
        type: u2
        # 00 02: ST60 ST32
        # 00 01: ST40 ST30 ST20
        # 00 00: SR60 SR40 SR30 SR20 CRs v1.x

      - type: u2
        valid: 1

      - id: cpu_attr16
        type: u2
        # 00 10: v2.8 ST32
        # 00 08: v2.7 ~ v2.0 v1.x

      - type: smart_types::null1

      - id: num_expansion_module
        type: u2

      - type: smart_types::nulls(2)

      - type: u1
        # 04: ST60 ST32
        # 03: SR60 ST40
        # 00: CR60s

      - size: 6

      - type: u2
        # 01 01: ST32 v2.8 ~ v2.5
        # 00 00: v2.4 ~ v2.0 v1.x

      - type: u2
        # 07 00: ST32 v2.8 v2.7
        # 01 00: v2.6
        # 00 00: v2.5 ~ v2.0 v1.x

      - type: u2
        valid: 0xfb00

      - id: cpu_attr17
        type: u2
        # 77 0f: v2.x ST32
        # 74 0f: v1.x

      - id: cpu_attr18
        type: u2
        # 00 02: ST32
        # 00 00: v2.x v1.x

      - id: cpu_attr19
        type: u2
        # 80 28: ST32
        # 30 00: ST SR v2.8
        # 28 00: ST SR v2.7 ~ v2.3
        # 00 00: ST SR v2.2 ~ v2.0 v1.x CR60
        # 08 00: CR60s

      - id: cpu_attr20
        type: u2
        # 00 00: ST32 v2.x
        # 10 37: v1.x

      - id: cpu_attr21
        size: 18

      - id: cpu_attr22
        type: u2
        # fe f0: ST32 v2.8
        # fe 80: v2.7 ~ v2.0 v1.x
        # ff 80: ST40v1.x

      - id: cpu_attr23
        size: 14

      - id: cpu_attr24
        type: u2
        # fb ff: ST32 v2.x CR
        # 7b ff: v1.x CRs

      - id: cpu_attr25
        type: u2
        # 9f dc: ST32 v2.8 ~ v2.3
        # 9f cc: v2.2 v2.1 v2.0 v1.x
        # 18 0c: CRs
        # 0f ec: CRv1.x ST40v1.x(template)

      - id: cpu_attr26
        size: 12

      - id: cpu_num_di
        type: u1

      - id: cpu_num_do
        type: u1

      - type: smart_types::nulls(2)

      - id: cpu_attr27
        type: u1
        valid: cpu_attr9

      - type: smart_types::nulls(8)

      - id: cpu_attr28
        type: u4
        # 04 00 cb 00: ST32 SR60 CRv2.x
        # 00 00 00 00: CR60s CRv1.x ST40v1.x

      - id: cpu_attr29
        type: u1
        # fa: ST32        --> 0xfa = 250
        # c8: v2.x v1.x   --> 0xc8 = 200

      - id: cpu_extended_attr
        size: 512
        if: version_or_num_signal_board == 2












































