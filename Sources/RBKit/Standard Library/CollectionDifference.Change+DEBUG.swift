extension CollectionDifference.Change: CustomDebugStringConvertible {
  public var debugDescription: String {
    let label = switch self {
    case .insert:
      "insert"
    case .remove:
      "remove"
    }
    return """
    .\(label):
      - offset: \(offset)
      - association: \(String(describing: associatedWith))
    """
  }
}
