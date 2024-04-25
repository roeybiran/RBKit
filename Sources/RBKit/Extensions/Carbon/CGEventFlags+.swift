import Cocoa
import Carbon

//extension CGEventFlags {
//  // https://github.com/JanX2/ShortcutRecorder/blob/07b065085e172d85b7b5a0f3cc05f6ed47ad5af1/Sources/ShortcutRecorder/include/ShortcutRecorder/SRCommon.h#L264
//  // https://github.com/sindresorhus/KeyboardShortcuts/blob/09e4a10ed6b65b3a40fe07b6bf0c84809313efc4/Sources/KeyboardShortcuts/Shortcut.swift#L15
//  public var cocoaFlags: Void {
//    let s = NSEvent.ModifierFlags(rawValue: UInt(rawValue))

//    let cocoaFlags = NSEvent.ModifierFlags(rawValue: UInt(rawValue))
//    let mask = Self
//      .mask
//      .filter { cocoaFlags.contains($0.cocoa) }
//      .map(\.carbon)
//      .reduce(0, |)
//    return CGEventFlags(rawValue: UInt64(mask))
//  }
//}

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
