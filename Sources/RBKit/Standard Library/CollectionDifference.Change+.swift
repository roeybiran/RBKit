extension CollectionDifference.Change {
  public var offset: Int {
    switch self {
    case .insert(let offset, _, _):
      offset
    case .remove(let offset, _, _):
      offset
    }
  }

  public var element: ChangeElement {
    switch self {
    case .insert(_, let element, _):
      element
    case .remove(_, let element, _):
      element
    }
  }

  public var associatedWith: Int? {
    switch self {
    case .insert(_, _, let associatedWith):
      associatedWith
    case .remove(_, _, let associatedWith):
      associatedWith
    }
  }
}

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
