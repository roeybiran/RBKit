public protocol TreeNodeProtocol {
  var children: [Self] { get set }

  func map<T: TreeNodeProtocol>(_ transform: (Self) throws -> T) rethrows -> T

  func firstNode(where predicate: (Self) -> Bool) -> Self?

  var descendants: [Self] { get }
}

public extension TreeNodeProtocol {
  func map<T: TreeNodeProtocol>(_ transform: (Self) throws -> T) rethrows -> T {
    var transformed = try transform(self)
    transformed.children = try children.map { try $0.map(transform) }
    return transformed
  }

  func firstNode(where predicate: (Self) -> Bool) -> Self? {
    if predicate(self) {
      return self
    }

    for child in children {
      if let match = child.firstNode(where: predicate) {
        return match
      }
    }

    return nil
  }

  var descendants: [Self] {
    children.concat(children.reduce(into: [], { $0.append(contentsOf: $1.descendants) }))
  }
}
