extension Array {
  public func dictionary<T: Hashable>(groupingBy closure: (Element) throws -> T) rethrows -> [T: [Element]] {
    try Dictionary(grouping: self, by: closure)
  }

  public func concat(_ other: Array) -> Array {
    self + other
  }

  public func concat(_ other: Element...) -> Array {
    self + other
  }
}
