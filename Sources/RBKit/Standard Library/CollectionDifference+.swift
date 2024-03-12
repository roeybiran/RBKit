extension CollectionDifference {
  public var steps: [Step] {
    let removals = removals
      .filter {
        $0.associatedWith == nil
      }
      .map {
        Step.removed(element: $0.element, from: $0.offset)
      }

    var _insertions: [Step] = []
    var moves: [Step] = []
    for insertion in insertions {
      if let associatedWith = insertion.associatedWith {
        moves.append(.moved(element: insertion.element, from: associatedWith, to: insertion.offset))
      } else {
        _insertions.append(.inserted(element: insertion.element, at: insertion.offset))
      }
    }
    return removals + moves + _insertions
  }
}

extension CollectionDifference: CustomDebugStringConvertible {
  public var debugDescription: String {
    if isEmpty {
      return "<NO DIFFERENCES>"
    } else {
      return """
      removals:
      \(removals.enumerated().map { "\($0)) \($1)" }.joined(separator: "\n") )
      insertions:
      \(insertions.enumerated().map { "\($0)) \($1)" }.joined(separator: "\n") )
      """
    }
  }
}

private extension CollectionDifference.Change {
  var offset: Int {
    switch self {
    case .insert(let offset, _, _):
      offset
    case .remove(let offset, _, _):
      offset
    }
  }

  var element: ChangeElement {
    switch self {
    case .insert(_, let element, _):
      element
    case .remove(_, let element, _):
      element
    }
  }

  var associatedWith: Int? {
    switch self {
    case .insert(_, _, let associatedWith):
      associatedWith
    case .remove(_, _, let associatedWith):
      associatedWith
    }
  }
}
