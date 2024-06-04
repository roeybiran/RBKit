import Foundation

// MARK: - NSKeyValueObservedChangeWrapper

public struct NSKeyValueObservedChangeWrapper<Value> {

  // MARK: Lifecycle

  public init(kind: NSKeyValueChange, newValue: Value?, oldValue: Value?, indexes: IndexSet?, isPrior: Bool) {
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

}

// MARK: Hashable

extension NSKeyValueObservedChangeWrapper: Hashable where Value: Hashable { }

// MARK: Equatable

extension NSKeyValueObservedChangeWrapper: Equatable where Value: Equatable { }

// MARK: Sendable

extension NSKeyValueObservedChangeWrapper: Sendable where Value: Sendable { }
