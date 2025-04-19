// MARK: - IdentityHashable

@dynamicMemberLookup
public protocol IdentityHashable: Hashable {
  associatedtype Value: Identifiable

  var value: Value { get }

  init(_ value: Value)
}

extension IdentityHashable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.value.id == rhs.value.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(value.id)
  }

  public subscript<Member>(dynamicMember keyPath: KeyPath<Value, Member>) -> Member {
    value[keyPath: keyPath]
  }
}
