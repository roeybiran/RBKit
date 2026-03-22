import Foundation

public struct KeyValueObservedChange<Value: Sendable>: Sendable {
  public init(
    kind: NSKeyValueChange = .setting,
    oldValue: Value? = nil,
    newValue: Value? = nil,
    indexes: IndexSet? = nil,
    isPrior: Bool = false,
  ) {
    self.kind = kind
    self.oldValue = oldValue
    self.newValue = newValue
    self.indexes = indexes
    self.isPrior = isPrior
  }

  public let kind: NSKeyValueChange
  public let oldValue: Value?
  public let newValue: Value?
  public let indexes: IndexSet?
  public let isPrior: Bool
}
