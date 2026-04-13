import Carbon
import Testing
@testable import RBKit

struct KeyTests {
  @Test
  func `raw values should match Events h`() {
    let cases: [(Key, Int)] = [
      (.a, Int(kVK_ANSI_A)),
      (.b, Int(kVK_ANSI_B)),
      (.c, Int(kVK_ANSI_C)),
      (.d, Int(kVK_ANSI_D)),
      (.e, Int(kVK_ANSI_E)),
      (.f, Int(kVK_ANSI_F)),
      (.g, Int(kVK_ANSI_G)),
      (.h, Int(kVK_ANSI_H)),
      (.i, Int(kVK_ANSI_I)),
      (.j, Int(kVK_ANSI_J)),
      (.k, Int(kVK_ANSI_K)),
      (.l, Int(kVK_ANSI_L)),
      (.m, Int(kVK_ANSI_M)),
      (.n, Int(kVK_ANSI_N)),
      (.o, Int(kVK_ANSI_O)),
      (.p, Int(kVK_ANSI_P)),
      (.q, Int(kVK_ANSI_Q)),
      (.r, Int(kVK_ANSI_R)),
      (.s, Int(kVK_ANSI_S)),
      (.t, Int(kVK_ANSI_T)),
      (.u, Int(kVK_ANSI_U)),
      (.v, Int(kVK_ANSI_V)),
      (.w, Int(kVK_ANSI_W)),
      (.x, Int(kVK_ANSI_X)),
      (.y, Int(kVK_ANSI_Y)),
      (.z, Int(kVK_ANSI_Z)),
      (.zero, Int(kVK_ANSI_0)),
      (.one, Int(kVK_ANSI_1)),
      (.two, Int(kVK_ANSI_2)),
      (.three, Int(kVK_ANSI_3)),
      (.four, Int(kVK_ANSI_4)),
      (.five, Int(kVK_ANSI_5)),
      (.six, Int(kVK_ANSI_6)),
      (.seven, Int(kVK_ANSI_7)),
      (.eight, Int(kVK_ANSI_8)),
      (.nine, Int(kVK_ANSI_9)),
      (.return, Int(kVK_Return)),
      (.backslash, Int(kVK_ANSI_Backslash)),
      (.backtick, Int(kVK_ANSI_Grave)),
      (.comma, Int(kVK_ANSI_Comma)),
      (.equal, Int(kVK_ANSI_Equal)),
      (.minus, Int(kVK_ANSI_Minus)),
      (.period, Int(kVK_ANSI_Period)),
      (.quote, Int(kVK_ANSI_Quote)),
      (.semicolon, Int(kVK_ANSI_Semicolon)),
      (.slash, Int(kVK_ANSI_Slash)),
      (.space, Int(kVK_Space)),
      (.tab, Int(kVK_Tab)),
      (.leftBracket, Int(kVK_ANSI_LeftBracket)),
      (.rightBracket, Int(kVK_ANSI_RightBracket)),
      (.escape, Int(kVK_Escape)),
      (.delete, Int(kVK_Delete)),
      (.deleteForward, Int(kVK_ForwardDelete)),
      (.contextualMenu, Int(kVK_ContextualMenu)),
      (.help, Int(kVK_Help)),
      (.home, Int(kVK_Home)),
      (.end, Int(kVK_End)),
      (.pageUp, Int(kVK_PageUp)),
      (.pageDown, Int(kVK_PageDown)),
      (.upArrow, Int(kVK_UpArrow)),
      (.rightArrow, Int(kVK_RightArrow)),
      (.downArrow, Int(kVK_DownArrow)),
      (.leftArrow, Int(kVK_LeftArrow)),
      (.f1, Int(kVK_F1)),
      (.f2, Int(kVK_F2)),
      (.f3, Int(kVK_F3)),
      (.f4, Int(kVK_F4)),
      (.f5, Int(kVK_F5)),
      (.f6, Int(kVK_F6)),
      (.f7, Int(kVK_F7)),
      (.f8, Int(kVK_F8)),
      (.f9, Int(kVK_F9)),
      (.f10, Int(kVK_F10)),
      (.f11, Int(kVK_F11)),
      (.f12, Int(kVK_F12)),
      (.f13, Int(kVK_F13)),
      (.f14, Int(kVK_F14)),
      (.f15, Int(kVK_F15)),
      (.f16, Int(kVK_F16)),
      (.f17, Int(kVK_F17)),
      (.f18, Int(kVK_F18)),
      (.f19, Int(kVK_F19)),
      (.f20, Int(kVK_F20)),
      (.mute, Int(kVK_Mute)),
      (.volumeUp, Int(kVK_VolumeUp)),
      (.volumeDown, Int(kVK_VolumeDown)),
      (.keypad0, Int(kVK_ANSI_Keypad0)),
      (.keypad1, Int(kVK_ANSI_Keypad1)),
      (.keypad2, Int(kVK_ANSI_Keypad2)),
      (.keypad3, Int(kVK_ANSI_Keypad3)),
      (.keypad4, Int(kVK_ANSI_Keypad4)),
      (.keypad5, Int(kVK_ANSI_Keypad5)),
      (.keypad6, Int(kVK_ANSI_Keypad6)),
      (.keypad7, Int(kVK_ANSI_Keypad7)),
      (.keypad8, Int(kVK_ANSI_Keypad8)),
      (.keypad9, Int(kVK_ANSI_Keypad9)),
      (.keypadClear, Int(kVK_ANSI_KeypadClear)),
      (.keypadDecimal, Int(kVK_ANSI_KeypadDecimal)),
      (.keypadDivide, Int(kVK_ANSI_KeypadDivide)),
      (.keypadEnter, Int(kVK_ANSI_KeypadEnter)),
      (.keypadEquals, Int(kVK_ANSI_KeypadEquals)),
      (.keypadMinus, Int(kVK_ANSI_KeypadMinus)),
      (.keypadMultiply, Int(kVK_ANSI_KeypadMultiply)),
      (.keypadPlus, Int(kVK_ANSI_KeypadPlus)),
      (.isoSection, Int(kVK_ISO_Section)),
      (.jisYen, Int(kVK_JIS_Yen)),
      (.jisUnderscore, Int(kVK_JIS_Underscore)),
      (.jisKeypadComma, Int(kVK_JIS_KeypadComma)),
      (.jisEisu, Int(kVK_JIS_Eisu)),
      (.jisKana, Int(kVK_JIS_Kana)),
    ]

    #expect(cases.count == Key.allCases.count)
    for (key, rawValue) in cases {
      #expect(key.rawValue == rawValue)
    }
    #expect(Key(rawValue: Int(kVK_Command)) == nil)
    #expect(Key(rawValue: Int(kVK_Shift)) == nil)
    #expect(Key(rawValue: Int(kVK_Control)) == nil)
    #expect(Key(rawValue: Int(kVK_Option)) == nil)
  }

  @Test
  func `id and keyCode should mirror rawValue`() {
    #expect(Key.a.id == Int(kVK_ANSI_A))
    #expect(Key.a.keyCode == Int(kVK_ANSI_A))
    #expect(Key.f20.id == Int(kVK_F20))
    #expect(Key.f20.keyCode == Int(kVK_F20))
  }
}
