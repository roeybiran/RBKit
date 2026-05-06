// MARK: - HotKeyManagerError

public enum HotKeyManagerError: Error, Equatable, Sendable, CustomStringConvertible {
  case carbonHotKeyExists
  case unknown
  case userConflict

  public var description: String {
    switch self {
    case .carbonHotKeyExists:
      "This keyboard shortcut is already in use by another application."
    case .userConflict:
      "The chosen keyboard shortcut conflicts with an existing one."
    case .unknown:
      "Something went wrong."
    }
  }
}
