import Foundation

public protocol DotSyntaxSettable: AnyObject {}

extension NSObject: DotSyntaxSettable {}

extension DotSyntaxSettable {
  @discardableResult
  public func set<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to value: T) -> Self {
    self[keyPath: keyPath] = value
    return self
  }
}
