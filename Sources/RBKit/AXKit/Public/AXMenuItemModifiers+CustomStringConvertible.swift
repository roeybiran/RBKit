import ApplicationServices
import Carbon

// MARK: - AXMenuItemModifiers + CustomStringConvertible

/// see AXAttributeConstants.h:994
extension AXMenuItemModifiers: @retroactive CustomStringConvertible {
  public var description: String {
    var result = ""
    if rawValue == 0x18 { return "🌐" } // undocumented
    if contains(.control) { result.append(kControlUnicode.unicodeString) }
    if contains(.option) { result.append(kOptionUnicode.unicodeString) }
    if contains(.shift) { result.append(kShiftUnicode.unicodeString) }
    if !contains(.noCommand) { result.append(kCommandUnicode.unicodeString) }
    return result
  }
}

extension Int {
  fileprivate var unicodeString: String {
    String(format: "%C", self)
  }
}
