// NSTreeController.h
// NSTreeNode.h

// MARK: - TreeNodeProtocol

public protocol TreeNodeProtocol {
  var children: [Self] { get set }
}

extension TreeNodeProtocol {
  /// Recursively returns children of self in a breadth-first order.
  public var descendants: [Self] {
    let descendantChildren = children.reduce(into: [Self]()) { result, child in
      result.append(contentsOf: child.descendants)
    }
    return children + descendantChildren
  }

  /// Apply `transform` on `self` and recursively on all of its descendants.
  public func recursiveMap<T: TreeNodeProtocol>(_ transform: (Self) throws -> T) rethrows -> T {
    var transformed = try transform(self)
    transformed.children = try children.map { try $0.recursiveMap(transform) }
    return transformed
  }

  public func recursiveCompactMap<T: TreeNodeProtocol>(_ transform: (Self) throws -> T?) rethrows -> T? {
    guard var transformed = try transform(self) else { return nil }
    transformed.children = try children.compactMap { try $0.recursiveCompactMap(transform) }
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
        children[next][indicesCopy] = newValue
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

extension Array where Element: TreeNodeProtocol {
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
