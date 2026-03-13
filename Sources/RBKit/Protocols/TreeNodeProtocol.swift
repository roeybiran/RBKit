// MARK: - TreeNodeProtocol

public protocol TreeNodeProtocol: Identifiable {
  associatedtype Children: RangeReplaceableCollection = [Self]
    where Children.Element == Self

  var children: Children { get set }
}

extension TreeNodeProtocol {
  /// Recursively returns children of self in a breadth-first order.
  public var descendants: [Self] {
    let descendantChildren = children.reduce(into: [Self]()) { result, child in
      result.append(contentsOf: child.descendants)
    }
    return Array(children) + descendantChildren
  }

  /// Apply `transform` on `self` and recursively on all of its descendants.
  public func recursiveMap<T: TreeNodeProtocol>(_ transform: (Self) throws -> T) rethrows -> T {
    var transformed = try transform(self)
    transformed.children = try children.reduce(into: T.Children()) { result, child in
      result.append(try child.recursiveMap(transform))
    }
    return transformed
  }

  public func recursiveCompactMap<T: TreeNodeProtocol>(_ transform: (Self) throws -> T?) rethrows -> T? {
    guard var transformed = try transform(self) else { return nil }
    transformed.children = try children.reduce(into: T.Children()) { result, child in
      if let child = try child.recursiveCompactMap(transform) {
        result.append(child)
      }
    }
    return transformed
  }

  public func recursiveFirst(where predicate: (Self) -> Bool) -> Self? {
    if predicate(self) {
      return self
    }

    for child in children {
      if let match = child.recursiveFirst(where: predicate) {
        return match
      }
    }

    return nil
  }

}

extension TreeNodeProtocol where Children.Index == Int {
  /// If `indices` is empty, returns `self`.
  public subscript(indices: [Int]) -> Self {
    get {
      if indices.isEmpty {
        return self
      } else {
        var indicesCopy = indices
        let next = indicesCopy.removeFirst()
        return children[next][indicesCopy]
      }
    }
    set {
      if indices.isEmpty {
        self = newValue
      } else {
        var indicesCopy = indices
        let next = indicesCopy.removeFirst()
        var elements = Array(children)
        elements[next][indicesCopy] = newValue
        children = .init(elements)
      }
    }
  }

  public subscript(indices: Int...) -> Self {
    get {
      self[indices]
    }
    set {
      self[indices] = newValue
    }
  }
}

extension Collection where Element: TreeNodeProtocol {
  public func recursiveMap<T: TreeNodeProtocol>(_ transform: (Element) throws -> T) rethrows -> [T] {
    try map {
      try $0.recursiveMap(transform)
    }
  }

  public func recursiveCompactMap<T: TreeNodeProtocol>(_ transform: (Element) throws -> T?) rethrows -> [T] {
    try compactMap {
      try $0.recursiveCompactMap(transform)
    }
  }

  public func recursiveFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    for child in self {
      if try predicate(child) {
        return child
      }

      if let found = try child.children.recursiveFirst(where: predicate) {
        return found
      }
    }
    return nil
  }
}
