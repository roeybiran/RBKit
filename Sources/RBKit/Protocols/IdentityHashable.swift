@dynamicMemberLookup
public protocol IdentityHashable: Hashable {
  associatedtype Value: Identifiable

  var value: Value { get }

  init(_ value: Value)
}

public extension IdentityHashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(value.id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value.id == rhs.value.id
  }

  subscript<Member>(dynamicMember keyPath: KeyPath<Value, Member>) -> Member {
    value[keyPath: keyPath]
  }
}
