public struct IdentifiedHash<T: Identifiable> {
  public let value: T

  public init(_ value: T) {
    self.value = value
  }
}

extension IdentifiedHash: Hashable where T.ID: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value.id)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value.id == rhs.value.id
  }
}
