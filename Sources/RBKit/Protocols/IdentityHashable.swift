// MARK: - IdentityHashable

@dynamicMemberLookup
public protocol IdentityHashable: Hashable {
  init(_ value: Value)

  associatedtype Value: Identifiable

  var value: Value { get }

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
