import ApplicationServices
import Carbon

// MARK: - MenuItemModifiers

public struct MenuItemModifiers: OptionSet, Sendable, Hashable, CustomStringConvertible {

  // MARK: Lifecycle

  public init(rawValue: UInt32) {
    self.rawValue = rawValue
    var label = ""
    if rawValue == 0x18 {
      self.label = "🌐"
      return
    }
    if rawValue & AXMenuItemModifiers.control.rawValue == AXMenuItemModifiers.control.rawValue {
      label.append(kControlUnicode.unicodeString)
    }
    if rawValue & AXMenuItemModifiers.option.rawValue == AXMenuItemModifiers.option.rawValue {
      label.append(kOptionUnicode.unicodeString)
    }
    if rawValue & AXMenuItemModifiers.shift.rawValue == AXMenuItemModifiers.shift.rawValue {
      label.append(kShiftUnicode.unicodeString)
    }
    if rawValue & AXMenuItemModifiers.noCommand.rawValue != AXMenuItemModifiers.noCommand.rawValue {
      label.append(kCommandUnicode.unicodeString)
    }
    self.label = label
  }

  // MARK: Public

  public static let control = Self(rawValue: AXMenuItemModifiers.control.rawValue)
  public static let option = Self(rawValue: AXMenuItemModifiers.option.rawValue)
  public static let shift = Self(rawValue: AXMenuItemModifiers.shift.rawValue)
  public static let noCommand = Self(rawValue: AXMenuItemModifiers.noCommand.rawValue)

  public let rawValue: UInt32
  public let label: String

  public var description: String {
    label
  }
}

extension Int {
  fileprivate var unicodeString: String {
    String(format: "%C", self)
  }
}
