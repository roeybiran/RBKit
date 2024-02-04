
extension CollectionDifference.Change {
  public enum Step {
    case inserted(element: ChangeElement, at: Int)
    case removed(element: ChangeElement, from: Int)
    case moved(element: ChangeElement, from: Int, to: Int)
  }
}

extension CollectionDifference.Change {
  public func step() -> Step {
    switch self {
    case .insert(let offset, let element, _):
      .inserted(element: element, at: offset)
    case .remove(let offset, let element, let associatedWith?):
      .moved(element: element, from: offset, to: associatedWith)
    case .remove(let offset, let element, associatedWith: .none):
      .removed(element: element, from: offset)
    }
  }
}

extension CollectionDifference.Change.Step: Equatable where ChangeElement: Equatable {}

extension CollectionDifference.Change.Step: Hashable where ChangeElement: Hashable {}
