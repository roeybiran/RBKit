import Carbon
import AppKit

extension NSEvent.ModifierFlags {
  public init(carbon flags: Int) {
    var modifiers = NSEvent.ModifierFlags()

    if flags & controlKey == controlKey {
      modifiers.insert(.control)
    }

    if flags & optionKey == optionKey {
      modifiers.insert(.option)
    }

    if flags & shiftKey == shiftKey {
      modifiers.insert(.shift)
    }

    if flags & cmdKey == cmdKey {
      modifiers.insert(.command)
    }

    self = modifiers
  }

  public var carbonized: Int {
    var modifierFlags = 0

    if contains(.control) {
      modifierFlags |= controlKey
    }

    if contains(.option) {
      modifierFlags |= optionKey
    }

    if contains(.shift) {
      modifierFlags |= shiftKey
    }

    if contains(.command) {
      modifierFlags |= cmdKey
    }

    return modifierFlags
  }

  public var hotkeyApplicable: Self {
    intersection(.deviceIndependentFlagsMask).subtracting([.capsLock, .numericPad, .help, .function])
  }
}

extension NSEvent.ModifierFlags: CustomStringConvertible {
  public var description: String {
    [
      (Self.control, kControlUnicode),
      (.option, kOptionUnicode),
      (.shift, kShiftUnicode),
      (.command, kCommandUnicode),
    ]
      .filter { contains($0.0) }
      .map(\.1)
      .map { String(format: "%C", $0) }
      .reduce("", +)
  }
}

