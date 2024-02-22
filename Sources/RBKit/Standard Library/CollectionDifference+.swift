extension CollectionDifference {
  public var steps: [Step] {
    var _removals: [Step] = []
    var _insertions: [Step] = []
    var _moves: [Step] = []
    for removal in removals where removal.associatedWith == nil {
      _removals.append(.removed(element: removal.element, from: removal.offset))
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

extension CollectionDifference: CustomDebugStringConvertible {
  public var debugDescription: String {
    isEmpty ? 
    "<NO DIFFERENCES>"
    : """
    removals:
      \(removals.enumerated().map { "\($0)) \($1)" }.joined(separator: "\n") )
    insertions:
      \(insertions.enumerated().map { "\($0)) \($1)" }.joined(separator: "\n") )
    """
  }
}
