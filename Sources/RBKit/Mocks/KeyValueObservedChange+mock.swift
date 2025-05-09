import Foundation

extension KeyValueObservedChange {
  public static func mock(
    _ value: Value?,
    kind: NSKeyValueChange = .insertion,
    oldValue: Value? = nil,
    indexes: IndexSet? = nil,
    isPrior: Bool = false
  ) -> Self {
    .init(kind: kind, newValue: value, oldValue: oldValue, indexes: indexes, isPrior: isPrior)
  }
}
