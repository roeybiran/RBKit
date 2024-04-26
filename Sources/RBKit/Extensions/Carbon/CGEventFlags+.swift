import Carbon

// MARK: - CGEventFlags + CustomDebugStringConvertible

extension CGEventFlags: CustomDebugStringConvertible {
  public var debugDescription: String {
    let flags = [
      (CGEventFlags.maskAlphaShift, "alphaShift"),
      (.maskShift, "shift"),
      (.maskControl, "control"),
      (.maskAlternate, "alternate"),
      (.maskCommand, "command"),
      (.maskHelp, "help"),
      (.maskSecondaryFn, "secondaryFn"),
      (.maskNumericPad, "numericPad"),
      (.maskNonCoalesced, "nonCoalesced"),
    ]
      .filter { contains($0.0) }
      .map(\.1)
      .joined(separator: ", ")

    return "\(flags) (rawValue: \(rawValue))"
  }
}
