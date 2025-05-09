import Foundation

extension NSKeyValueChange: @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .insertion:
      "insertion"
    case .removal:
      "removal"
    case .replacement:
      "replacement"
    case .setting:
      "setting"
    @unknown default:
      "unknown (\(rawValue))"
    }
  }
}
