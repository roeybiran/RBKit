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
    case let .inserted(_, at):
      "inserted at \(at)"
    case let .removed(_, from):
      "removed from \(from)"
    case let .moved(_, from, to):
      "moved from \(from) to \(to)"
    }
  }
}
