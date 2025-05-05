import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NSObjectClient

@DependencyClient
public struct NSObjectClient: Sendable {
  public var addObserver:
    @Sendable (
      _ observed: NSObject,
      _ observer: NSObject,
      _ keyPath: String,
      _ options: NSKeyValueObservingOptions,
      _ context: UnsafeMutableRawPointer?) -> Void
  public var removeObserver:
    @Sendable (
      _ observed: NSObject, _ observer: NSObject, _ keyPath: String,
      _ context: UnsafeMutableRawPointer?)
    -> Void
}

// MARK: DependencyKey

extension NSObjectClient: DependencyKey {
  public static let liveValue = Self(
    addObserver: { observed, observer, keyPath, options, context in
      observed.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
    },
    removeObserver: { observed, observer, keyPath, context in
      observed.removeObserver(observer, forKeyPath: keyPath, context: context)
    })

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsObjectClient: NSObjectClient {
    get { self[NSObjectClient.self] }
    set { self[NSObjectClient.self] = newValue }
  }
}
