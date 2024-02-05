extension CollectionDifference {
  public enum Step {
    case inserted(element: ChangeElement, at: Int)
    case removed(element: ChangeElement, from: Int)
    case moved(element: ChangeElement, from: Int, to: Int)
  }
}

extension CollectionDifference.Step: Equatable where ChangeElement: Equatable {}

extension CollectionDifference.Step: Hashable where ChangeElement: Hashable {}

extension CollectionDifference.Step: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .inserted(let element, let at):
      "inserted “\(element)” at \(at)"
    case .removed(let element, let at):
      "removed “\(element)” from \(at)"
    case .moved(let element, let from, let to):
      "moved “\(element)” from \(from) to \(to)"
    }
  }
}

extension CollectionDifference.Change {
  public var step: CollectionDifference.Step {
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
