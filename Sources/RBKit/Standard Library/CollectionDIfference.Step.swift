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
      "inserted “\(element.self)” at \(at)"
    case .removed(let element, let at):
      "removed “\(element.self)” from \(at)"
    case .moved(let element, let from, let to):
      "moved “\(element.self)” from \(from) to \(to)"
    }
  }
}
