import AppKit
import Carbon

extension NSEvent.ModifierFlags {

  // MARK: Lifecycle

  public init(carbon flags: Int) {
    self = [
      (cocoa: Self.control, carbon: controlKey),
      (.option, optionKey),
      (.shift, shiftKey),
      (.command, cmdKey),
    ].reduce(into: Self()) { partialResult, pair in
      if flags & pair.carbon == pair.carbon {
        partialResult.insert(pair.cocoa)
      }
    }
  }

  // MARK: Public

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

// MARK: - NSEvent.ModifierFlags + CustomStringConvertible

extension NSEvent.ModifierFlags: CustomStringConvertible {
  public var description: String {
    [
      (Self.control, kControlUnicode),
      (.option, kOptionUnicode),
      (.shift, kShiftUnicode),
      (.command, kCommandUnicode),
    ]
    .filter {
      contains($0.0)
    }
    .map {
      String(format: "%C", $0.1)
    }
    .reduce("", +)
  }
}
