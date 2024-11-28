import Foundation

// MARK: - DotSyntaxSettable

public protocol DotSyntaxSettable: AnyObject {}

// MARK: - NSObject + DotSyntaxSettable

extension NSObject: DotSyntaxSettable {}

extension DotSyntaxSettable {
  @discardableResult
  public func set<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to value: T) -> Self {
    self[keyPath: keyPath] = value
    return self
  }
}
