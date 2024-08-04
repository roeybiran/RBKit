import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NSObjectClient

@DependencyClient
public struct NSObjectClient {
  public var addObserver: (
    _ observee: NSObject,
    _ observer: NSObject,
    _ keyPath: String,
    _ options: NSKeyValueObservingOptions,
    _ context: UnsafeMutableRawPointer?) -> Void
  public var removeObserver: (_ observee: NSObject, _ observer: NSObject, _ keyPath: String, _ context: UnsafeMutableRawPointer?)
    -> Void
}

// MARK: DependencyKey

extension NSObjectClient: DependencyKey {
  public static let liveValue: Self = .init(
    addObserver: { observee, observer, keyPath, options, context in
      observee.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
    },
    removeObserver: { observee, observer, keyPath, context in
      observee.removeObserver(observer, forKeyPath: keyPath, context: context)
    })

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsObjectClient: NSObjectClient {
    get { self[NSObjectClient.self] }
    set { self[NSObjectClient.self] = newValue }
  }
}
