// https://www.swiftbysundell.com/articles/the-power-of-key-paths-in-swift/

extension Sequence {
  public func sorted(by keyPath: KeyPath<Element, some Comparable>) -> [Element] {
    sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
  }

  public func toArray() -> [Element] {
    Array(self)
  }

  public func dictionary<T: Hashable>(groupingBy closure: (Element) throws -> T) rethrows -> [T:
    [Element]]
  {
    try Dictionary(grouping: self, by: closure)
  }
}

extension Sequence where Element: Hashable {
  public func toSet() -> Set<Element> {
    .init(self)
  }
}
