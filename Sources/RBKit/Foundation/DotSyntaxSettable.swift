import Foundation

public protocol DotSyntaxSettable: AnyObject {}

extension NSObject: DotSyntaxSettable {}

extension DotSyntaxSettable {
  @discardableResult
  public func setting<T>(_ property: ReferenceWritableKeyPath<Self, T>, to value: T) -> Self {
    self[keyPath: property] = value
    return self
  }
}
