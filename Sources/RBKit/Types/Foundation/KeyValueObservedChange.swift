import Foundation

// MARK: - KeyValueObservedChange

public struct KeyValueObservedChange<Value> {

  // MARK: Lifecycle

  public init(
    kind: NSKeyValueChange, newValue: Value?, oldValue: Value?, indexes: IndexSet?, isPrior: Bool
  ) {
    self.kind = kind
    self.newValue = newValue
    self.oldValue = oldValue
    self.indexes = indexes
    self.isPrior = isPrior
  }

  public init(_ change: NSKeyValueObservedChange<Value>) {
    kind = change.kind
    newValue = change.newValue
    oldValue = change.oldValue
    indexes = change.indexes
    isPrior = change.isPrior
  }

  // MARK: Public

  public let kind: NSKeyValueChange
  public let newValue: Value?
  public let oldValue: Value?
  public let indexes: IndexSet?
  public let isPrior: Bool

  // MARK: Internal

  func map<T>(_ transform: (Value) throws -> T) rethrows -> KeyValueObservedChange<T> {
    .init(
      kind: kind,
      newValue: try newValue.map(transform),
      oldValue: try oldValue.map(transform),
      indexes: indexes,
      isPrior: isPrior)
  }
}

// MARK: Hashable

extension KeyValueObservedChange: Hashable where Value: Hashable {}

// MARK: Equatable

extension KeyValueObservedChange: Equatable where Value: Equatable {}

// MARK: Sendable

extension KeyValueObservedChange: Sendable where Value: Sendable {}
