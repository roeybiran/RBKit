public protocol TreeNodeProtocol {
  var children: [Self] { get set }

  /// Recursively apply `transform` on all descendants of `Self`.
  func map<T: TreeNodeProtocol>(_ transform: (Self) throws -> T) rethrows -> T

  func first(where predicate: (Self) -> Bool) -> Self?

  /// Children are returned in a breadth-first order.
  var descendants: [Self] { get }

  subscript(indices: [Int]) -> Self { get set }

  subscript(indices: Int...) -> Self { get set }
}

public extension TreeNodeProtocol {
  func map<T: TreeNodeProtocol>(_ transform: (Self) throws -> T) rethrows -> T {
    var transformed = try transform(self)
    transformed.children = try children.map { try $0.map(transform) }
    return transformed
  }

  func first(where predicate: (Self) -> Bool) -> Self? {
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

  var descendants: [Self] {
    children.concat(children.reduce(into: [], { $0.append(contentsOf: $1.descendants) }))
  }

  subscript(indices: [Int]) -> Self {
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

  subscript(indices: Int...) -> Self {
    get { self[indices] }
    set { self[indices] = newValue }
  }
}
