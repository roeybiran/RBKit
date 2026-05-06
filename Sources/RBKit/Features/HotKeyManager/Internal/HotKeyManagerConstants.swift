import AppKit

extension String {
  static let DEFAULTS_ALL_HOT_KEYS_KEY = Self("RBShortcutKit_Shortcuts")
  static let DEFAULTS_KEY_CODE_KEY = Self("keyCode")
  static let DEFAULTS_MODIFIERS_KEY = Self("modifiers")
}

extension FourCharCode {
  static let HOT_KEY_SIGNATURE: Self = {
    let signature = "RBKS" // "Roey Biran Keyboard Shortcuts"
    assert(signature.count == 4)
    var code: FourCharCode = 0
    for char in signature.utf16 {
      code = (code << 8) + FourCharCode(char)
    }
    return code
  }()
}
