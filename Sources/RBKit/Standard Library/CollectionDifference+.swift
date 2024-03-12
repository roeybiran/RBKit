extension CollectionDifference {
  public var steps: [Step] {
    var _removals: [Step] = []
    var _insertions: [Step] = []
    var _moves: [Step] = []

    for removal in removals where removal.associatedWith == nil {
      _removals.append(Step.removed(element: removal.element, from: removal.offset))
    }

    for insertion in insertions {
      if let associatedWith = insertion.associatedWith {
        _moves.append(.moved(element: insertion.element, from: associatedWith, to: insertion.offset))
      } else {
        _insertions.append(.inserted(element: insertion.element, at: insertion.offset))
      }
    }

    return _removals + _moves + _insertions
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
