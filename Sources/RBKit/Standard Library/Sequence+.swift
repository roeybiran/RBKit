// https://www.swiftbysundell.com/articles/the-power-of-key-paths-in-swift/

extension Sequence {
  public func sorted(by keyPath: KeyPath<Element, some Comparable>) -> [Element] {
    sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
  }

  public func toArray() -> [Element] {
    Array(self)
  }
}

