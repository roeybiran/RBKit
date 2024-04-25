import AppKit

extension NSApplication.ActivationPolicy: CustomDebugStringConvertible {
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
