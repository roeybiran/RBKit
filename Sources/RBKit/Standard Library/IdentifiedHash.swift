@dynamicMemberLookup
public struct IdentifiedHash<Value: Identifiable> {
  public let value: Value

  public init(_ value: Value) {
    self.value = value
  }
  
  public subscript<Member>(dynamicMember keyPath: KeyPath<Value, Member>) -> Member {
    value[keyPath: keyPath]
  }
}

extension IdentifiedHash: Hashable where Value.ID: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value.id)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value.id == rhs.value.id
  }
}
