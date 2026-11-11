@dynamicMemberLookup
public struct DiffableOutlineItem<Value: Identifiable & Hashable & Sendable>: Hashable, Identifiable, Sendable {

  // MARK: Lifecycle

  public init(_ value: Value, children: [Self] = []) {
    self.value = value
    self.children = children
  }

  // MARK: Public

  public typealias ID = Value.ID

  public var value: Value
  public var children: [Self]

  public var id: ID {
    value.id
  }

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  public subscript<Member>(dynamicMember keyPath: KeyPath<Value, Member>) -> Member {
    value[keyPath: keyPath]
  }

  public subscript(_ index: Int) -> Self {
    children[index]
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
