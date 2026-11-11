import RBKit

extension Key {
  enum DisplayLabelStyle {
    case short
    case long
  }

  func label(_ style: DisplayLabelStyle) -> String {
    switch self {
    case .a: "A"

    case .b: "B"

    case .c: "C"

    case .d: "D"

    case .e: "E"

    case .f: "F"

    case .g: "G"

    case .h: "H"

    case .i: "I"

    case .j: "J"

    case .k: "K"

    case .l: "L"

    case .m: "M"

    case .n: "N"

    case .o: "O"

    case .p: "P"

    case .q: "Q"

    case .r: "R"

    case .s: "S"

    case .t: "T"

    case .u: "U"

    case .v: "V"

    case .w: "W"

    case .x: "X"

    case .y: "Y"

    case .z: "Z"

    case .zero: "0"

    case .one: "1"

    case .two: "2"

    case .three: "3"

    case .four: "4"

    case .five: "5"

    case .six: "6"

    case .seven: "7"

    case .eight: "8"

    case .nine: "9"

    case .return:
      switch style {
      case .short: "↩"
      case .long: "Return (↩)"
      }

    case .backslash:
      switch style {
      case .short: "\\"
      case .long: "Backslash (\\)"
      }

    case .backtick:
      switch style {
      case .short: "`"
      case .long: "Backtick (`)"
      }

    case .comma:
      switch style {
      case .short: ","
      case .long: "Comma (,)"
      }

    case .equal:
      switch style {
      case .short: "="
      case .long: "Equal (=)"
      }

    case .minus:
      switch style {
      case .short: "-"
      case .long: "Minus (-)"
      }

    case .period:
      switch style {
      case .short: "."
      case .long: "Period (.)"
      }

    case .quote:
      switch style {
      case .short: "'"
      case .long: "Quote (')"
      }

    case .semicolon:
      switch style {
      case .short: ";"
      case .long: "Semicolon (;)"
      }

    case .slash:
      switch style {
      case .short: "/"
      case .long: "Slash (/)"
      }

    case .space:
      switch style {
      case .short: "␣"
      case .long: "Space (␣)"
      }

    case .tab:
      switch style {
      case .short: "⇥"
      case .long: "Tab (⇥)"
      }

    case .leftBracket:
      switch style {
      case .short: "["
      case .long: "Left Bracket ([)"
      }

    case .rightBracket:
      switch style {
      case .short: "]"
      case .long: "Right Bracket (])"
      }

    case .pageUp:
      switch style {
      case .short: "⇞"
      case .long: "Page Up (⇞)"
      }

    case .pageDown:
      switch style {
      case .short: "⇟"
      case .long: "Page Down (⇟)"
      }

    case .home:
      switch style {
      case .short: "↖"
      case .long: "Home (↖)"
      }

    case .end:
      switch style {
      case .short: "↘"
      case .long: "End (↘)"
      }

    case .upArrow:
      switch style {
      case .short: "↑"
      case .long: "Up Arrow (↑)"
      }

    case .rightArrow:
      switch style {
      case .short: "→"
      case .long: "Right Arrow (→)"
      }

    case .downArrow:
      switch style {
      case .short: "↓"
      case .long: "Down Arrow (↓)"
      }

    case .leftArrow:
      switch style {
      case .short: "←"
      case .long: "Left Arrow (←)"
      }

    case .escape:
      switch style {
      case .short: "⎋"
      case .long: "Escape (⎋)"
      }

    case .delete:
      switch style {
      case .short: "⌫"
      case .long: "Delete (⌫)"
      }

    case .deleteForward:
      switch style {
      case .short: "⌦"
      case .long: "Forward Delete (⌦)"
      }

    case .contextualMenu: "Contextual Menu"

    case .help: "Help"

    case .mute: "Mute"

    case .volumeUp: "Volume Up"

    case .volumeDown: "Volume Down"

    case .f1: "F1"

    case .f2: "F2"

    case .f3: "F3"

    case .f4: "F4"

    case .f5: "F5"

    case .f6: "F6"

    case .f7: "F7"

    case .f8: "F8"

    case .f9: "F9"

    case .f10: "F10"

    case .f11: "F11"

    case .f12: "F12"

    case .f13: "F13"

    case .f14: "F14"

    case .f15: "F15"

    case .f16: "F16"

    case .f17: "F17"

    case .f18: "F18"

    case .f19: "F19"

    case .f20: "F20"

    case .keypad0: "Keypad 0"

    case .keypad1: "Keypad 1"

    case .keypad2: "Keypad 2"

    case .keypad3: "Keypad 3"

    case .keypad4: "Keypad 4"

    case .keypad5: "Keypad 5"

    case .keypad6: "Keypad 6"

    case .keypad7: "Keypad 7"

    case .keypad8: "Keypad 8"

    case .keypad9: "Keypad 9"

    case .keypadClear: "Keypad Clear"

    case .keypadDecimal: "Keypad Decimal"

    case .keypadDivide: "Keypad Divide"

    case .keypadEnter: "Keypad Enter"

    case .keypadEquals: "Keypad Equals"

    case .keypadMinus: "Keypad Minus"

    case .keypadMultiply: "Keypad Multiply"

    case .keypadPlus: "Keypad Plus"

    case .isoSection: "ISO Section"

    case .jisYen: "JIS Yen"

    case .jisUnderscore: "JIS Underscore"

    case .jisKeypadComma: "JIS Keypad Comma"

    case .jisEisu: "JIS Eisu"

    case .jisKana: "JIS Kana"
    }
  }
}
