// NSTreeController.h
// NSTreeNode.h

public protocol TreeNodeProtocol {
  var children: [Self] { get set }
}

extension TreeNodeProtocol {
  /// Apply `transform` on `self` and recursively on all of its descendants.
  public func map<T: TreeNodeProtocol>(_ transform: (Self) throws -> T) rethrows -> T {
    var transformed = try transform(self)
    transformed.children = try children.map { try $0.map(transform) }
    return transformed
  }

  public func first(where predicate: (Self) -> Bool) -> Self? {
    if predicate(self) {
      return self
    }

    for child in children {
      if let match = child.first(where: predicate) {
        return match
      }
    }

    return nil
  }

  /// Recursively returns children of self in a breadth-first order.
  public var descendants: [Self] {
    children.concat(children.reduce(into: [], { $0.append(contentsOf: $1.descendants) }))
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
