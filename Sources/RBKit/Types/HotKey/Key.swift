import Carbon

// MARK: - Key

public enum Key: Int, CaseIterable, Identifiable, Sendable {
  case a = 0x00 // kVK_ANSI_A
  case b = 0x0B // kVK_ANSI_B
  case c = 0x08 // kVK_ANSI_C
  case d = 0x02 // kVK_ANSI_D
  case e = 0x0E // kVK_ANSI_E
  case f = 0x03 // kVK_ANSI_F
  case g = 0x05 // kVK_ANSI_G
  case h = 0x04 // kVK_ANSI_H
  case i = 0x22 // kVK_ANSI_I
  case j = 0x26 // kVK_ANSI_J
  case k = 0x28 // kVK_ANSI_K
  case l = 0x25 // kVK_ANSI_L
  case m = 0x2E // kVK_ANSI_M
  case n = 0x2D // kVK_ANSI_N
  case o = 0x1F // kVK_ANSI_O
  case p = 0x23 // kVK_ANSI_P
  case q = 0x0C // kVK_ANSI_Q
  case r = 0x0F // kVK_ANSI_R
  case s = 0x01 // kVK_ANSI_S
  case t = 0x11 // kVK_ANSI_T
  case u = 0x20 // kVK_ANSI_U
  case v = 0x09 // kVK_ANSI_V
  case w = 0x0D // kVK_ANSI_W
  case x = 0x07 // kVK_ANSI_X
  case y = 0x10 // kVK_ANSI_Y
  case z = 0x06 // kVK_ANSI_Z

  case zero = 0x1D // kVK_ANSI_0
  case one = 0x12 // kVK_ANSI_1
  case two = 0x13 // kVK_ANSI_2
  case three = 0x14 // kVK_ANSI_3
  case four = 0x15 // kVK_ANSI_4
  case five = 0x17 // kVK_ANSI_5
  case six = 0x16 // kVK_ANSI_6
  case seven = 0x1A // kVK_ANSI_7
  case eight = 0x1C // kVK_ANSI_8
  case nine = 0x19 // kVK_ANSI_9

  case `return` = 0x24 // kVK_Return
  case backslash = 0x2A // kVK_ANSI_Backslash
  case backtick = 0x32 // kVK_ANSI_Grave
  case comma = 0x2B // kVK_ANSI_Comma
  case equal = 0x18 // kVK_ANSI_Equal
  case minus = 0x1B // kVK_ANSI_Minus
  case period = 0x2F // kVK_ANSI_Period
  case quote = 0x27 // kVK_ANSI_Quote
  case semicolon = 0x29 // kVK_ANSI_Semicolon
  case slash = 0x2C // kVK_ANSI_Slash
  case space = 0x31 // kVK_Space
  case tab = 0x30 // kVK_Tab
  case leftBracket = 0x21 // kVK_ANSI_LeftBracket
  case rightBracket = 0x1E // kVK_ANSI_RightBracket

  case escape = 0x35 // kVK_Escape
  case delete = 0x33 // kVK_Delete
  case deleteForward = 0x75 // kVK_ForwardDelete
  case contextualMenu = 0x6E // kVK_ContextualMenu
  case help = 0x72 // kVK_Help
  case home = 0x73 // kVK_Home
  case end = 0x77 // kVK_End
  case pageUp = 0x74 // kVK_PageUp
  case pageDown = 0x79 // kVK_PageDown
  case upArrow = 0x7E // kVK_UpArrow
  case rightArrow = 0x7C // kVK_RightArrow
  case downArrow = 0x7D // kVK_DownArrow
  case leftArrow = 0x7B // kVK_LeftArrow

  case f1 = 0x7A // kVK_F1
  case f2 = 0x78 // kVK_F2
  case f3 = 0x63 // kVK_F3
  case f4 = 0x76 // kVK_F4
  case f5 = 0x60 // kVK_F5
  case f6 = 0x61 // kVK_F6
  case f7 = 0x62 // kVK_F7
  case f8 = 0x64 // kVK_F8
  case f9 = 0x65 // kVK_F9
  case f10 = 0x6D // kVK_F10
  case f11 = 0x67 // kVK_F11
  case f12 = 0x6F // kVK_F12
  case f13 = 0x69 // kVK_F13
  case f14 = 0x6B // kVK_F14
  case f15 = 0x71 // kVK_F15
  case f16 = 0x6A // kVK_F16
  case f17 = 0x40 // kVK_F17
  case f18 = 0x4F // kVK_F18
  case f19 = 0x50 // kVK_F19
  case f20 = 0x5A // kVK_F20

  case mute = 0x4A // kVK_Mute
  case volumeUp = 0x48 // kVK_VolumeUp
  case volumeDown = 0x49 // kVK_VolumeDown

  case keypad0 = 0x52 // kVK_ANSI_Keypad0
  case keypad1 = 0x53 // kVK_ANSI_Keypad1
  case keypad2 = 0x54 // kVK_ANSI_Keypad2
  case keypad3 = 0x55 // kVK_ANSI_Keypad3
  case keypad4 = 0x56 // kVK_ANSI_Keypad4
  case keypad5 = 0x57 // kVK_ANSI_Keypad5
  case keypad6 = 0x58 // kVK_ANSI_Keypad6
  case keypad7 = 0x59 // kVK_ANSI_Keypad7
  case keypad8 = 0x5B // kVK_ANSI_Keypad8
  case keypad9 = 0x5C // kVK_ANSI_Keypad9
  case keypadClear = 0x47 // kVK_ANSI_KeypadClear
  case keypadDecimal = 0x41 // kVK_ANSI_KeypadDecimal
  case keypadDivide = 0x4B // kVK_ANSI_KeypadDivide
  case keypadEnter = 0x4C // kVK_ANSI_KeypadEnter
  case keypadEquals = 0x51 // kVK_ANSI_KeypadEquals
  case keypadMinus = 0x4E // kVK_ANSI_KeypadMinus
  case keypadMultiply = 0x43 // kVK_ANSI_KeypadMultiply
  case keypadPlus = 0x45 // kVK_ANSI_KeypadPlus

  case isoSection = 0x0A // kVK_ISO_Section
  case jisYen = 0x5D // kVK_JIS_Yen
  case jisUnderscore = 0x5E // kVK_JIS_Underscore
  case jisKeypadComma = 0x5F // kVK_JIS_KeypadComma
  case jisEisu = 0x66 // kVK_JIS_Eisu
  case jisKana = 0x68 // kVK_JIS_Kana

  // MARK: Public

  public var id: Int {
    rawValue
  }

  public var keyCode: Int {
    rawValue
  }

  public var isFunctionKey: Bool {
    switch self {
    case .f1, .f2, .f3, .f4, .f5, .f6, .f7, .f8, .f9, .f10, .f11, .f12, .f13, .f14, .f15, .f16, .f17, .f18,
         .f19, .f20:
      true
    default:
      false
    }
  }
}
