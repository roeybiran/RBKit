import Foundation

extension NSKeyValueChange: CustomDebugStringConvertible {
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
