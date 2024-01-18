public enum ChangeType<Element> {
  case inserted(element: Element, at: Int)
  case removed(element: Element, from: Int)
  case moved(element: Element, from: Int, to: Int)
}

extension ChangeType {
  public init(_ collectionDifferentChange: CollectionDifference<Element>.Change) {
    switch collectionDifferentChange {
    case .insert(let offset, let element, _):
      self = .inserted(element: element, at: offset)
    case .remove(let offset, let element, let associatedWith?):
      self = .moved(element: element, from: offset, to: associatedWith)
    case .remove(let offset, let element, associatedWith: .none):
      self = .removed(element: element, from: offset)
    }
  }
}
