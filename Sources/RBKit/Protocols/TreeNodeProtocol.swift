// NSTreeController.h
// NSTreeNode.h

import IdentifiedCollections

// MARK: - TreeNodeProtocol

public protocol TreeNodeProtocol: Identifiable {
  var children: IdentifiedArrayOf<Self> { get set }
}

extension TreeNodeProtocol {
  /// Recursively returns children of self in a breadth-first order.
  public var descendants: [Self] {
    let children = children.elements
    let descendantChildren = children.reduce(into: [Self]()) { result, child in
      result.append(contentsOf: child.descendants)
    }
    return children + descendantChildren
  }

  /// Apply `transform` on `self` and recursively on all of its descendants.
  public func recursiveMap<T: TreeNodeProtocol>(_ transform: (Self) throws -> T) rethrows -> T {
    var transformed = try transform(self)
    transformed.children = .init(uniqueElements: try children.map { try $0.recursiveMap(transform) })
    return transformed
  }

  public func recursiveCompactMap<T: TreeNodeProtocol>(_ transform: (Self) throws -> T?) rethrows -> T? {
    guard var transformed = try transform(self) else { return nil }
    transformed.children = .init(uniqueElements: try children.compactMap { try $0.recursiveCompactMap(transform) })
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
        return children.elements[next][indicesCopy]
      }
    }
    set {
      if indices.isEmpty {
        self = newValue
      } else {
        var indicesCopy = indices
        let next = indicesCopy.removeFirst()
        var elements = children.elements
        elements[next][indicesCopy] = newValue
        children = .init(uniqueElements: elements)
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

extension IdentifiedArray where Element: TreeNodeProtocol, ID == Element.ID {
  public func recursiveMap<T: TreeNodeProtocol>(_ transform: (Element) throws -> T) rethrows -> IdentifiedArrayOf<T> {
    try .init(uniqueElements: map {
      try $0.recursiveMap(transform)
    })
  }

  public func recursiveCompactMap<T: TreeNodeProtocol>(_ transform: (Element) throws -> T?) rethrows -> IdentifiedArrayOf<T> {
    try .init(uniqueElements: compactMap {
      try $0.recursiveCompactMap(transform)
    })
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
