import AppKit

extension NSApplication.ActivationPolicy: @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .accessory:
      "accessory"
    case .prohibited:
      "prohibited"
    case .regular:
      "regular"
    @unknown default:
      "unknown (\(rawValue))"
    }
  }
}
