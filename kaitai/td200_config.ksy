meta:
  id: td200_config
  endian: le
  imports:
    - smart_types

seq:
  # - size: 0x8d71d
  # - size: 0x1bd07e
  # - size: 0x5a2a4
  # - size: 0x5cf2b
  # - size: 0x59e15
  # - size: 0xe7fd
  # - size: 0x12fe1
  # - size: 0x5d2e6

  - type: u1
    valid: 2

  - id: num_td
    type: u4

  - id: td
    type: td
    repeat: expr
    repeat-expr: num_td


types:
  td:
    seq:
      - id: marker
        type: u2
        valid: 0x0103

      - id: flag_1
        type: u4

      - id: password
        type: u4

      - id: enable_tod_menu
        type: u4

      - id: enable_force_menu
        type: u4
      - id: enable_program_memory_card_menu
        type: u4
      - id: enable_change_cpu_operating_mode_menu
        type: u4
      - id: enable_edit_v_memory_menu
        type: u4

      - id: num_lang
        type: u4

      - id: lang
        type: lang
        repeat: expr
        repeat-expr: num_lang

      - id: num_menu
        type: u4
        # valid: 1

      - id: menu
        type: menu
        repeat: expr
        repeat-expr: num_menu

      - id: num_keypad_info
        type: u4

      - id: keypad_info
        type: keypad_info
        repeat: expr
        repeat-expr: num_keypad_info

      # - type: u4

      - id: num_alarm
        type: u4
      - size: 10

      - id: alarm
        type: alarm
        repeat: expr
        repeat-expr: num_alarm

      - type: u2

      - id: memory_allocation_offset
        type: u4

      - id: name
        type: smart_types::strl

      - type: smart_types::nulls(4)

      - id: symbolic_name
        type: smart_types::strl

      - size: 18






  alarm:
    seq:
      - id: num_alarm_line
        type: u4

      - type: line
        repeat: expr
        repeat-expr: num_alarm_line * _parent.num_lang

      - id: name
        type: smart_types::strl

      - id: comment
        type: smart_types::strl

      - type: smart_types::nulls(4)

      - id: symbolic_name
        type: smart_types::strl

      - id: require_operator_ack
        type: u4

      - id: ack_bit_symbolic_name
        type: smart_types::strl

      - size: 10




  menu:
    seq:
      - type: u1
      - id: num_submenu
        type: u4
      - type: u1
        if: num_submenu > 0
      - type: u4
        valid: 3

      - type: u2
        if: num_submenu > 0
      - type: u2
        if: num_submenu > 0
      - type: u1
        if: num_submenu > 0
      - id: num_line
        type: u4
        if: num_submenu > 0

      - id: submenu
        type: submenu
        repeat: expr
        repeat-expr: num_submenu

      - size: 16
        if: num_submenu > 0

      - id: name
        type: smart_types::strl
        repeat: expr
        repeat-expr: _parent.num_lang
        # menu is repeated index per language
        # index 0: lang0, lang1, lang2
        # index 1: lang0, lang1, lang2
        # and so on
        # I wonder if menu displays are also like that?
        # as in, repeated line by line per language?

      - id: comment
        type: smart_types::strl







  submenu:
    seq:
      - size: 26
        if: _parent.num_submenu == 3
        # this is a blatantly wrong hack
        # won't work with real data
        # need to figure out when to have this block and when not
        # maybe we need to reanalyze this block
        # or maybe we need to look elsewhere

      - id: line
        type: line
        repeat: expr
        repeat-expr: _parent._parent.num_lang * _parent.num_line

      - id: submenu_name
        type: smart_types::strl

      - id: submenu_comment
        type: smart_types::strl






  line:
    seq:
      - type: u1

      - id: var
        type: var
        repeat: expr
        repeat-expr: 2

      - type: smart_types::rec(2,1)

      - type: u4


  var:
    seq:
      - id: identifier
        type: u4

      - type: u1
        if: identifier > 0

      - type: u4
        if: identifier > 0

      - type: u4
        if: identifier > 0




  lang:
    seq:
      - type: u1
        valid: 1

      - id: name
        type: smart_types::strl

      - id: lang_code
        type: u4
        # 1: English
        # 2: German
        # 3: French
        # 4: Italian
        # 5: Spanish
        # 6: Chinese

      - id: charset
        type: u4
        # this is a bit field
        # 0: Original TD200
        # 256: Simplified Chinese
        # 128: Bar Graph


  keypad_info:
    seq:
      - id: marker
        type: u1
        valid: 1

      - id: key_name
        type: smart_types::strl

      - id: key_name_with_td
        type: smart_types::strl

      - type: u4

      - id: with_shift
        type: u4


