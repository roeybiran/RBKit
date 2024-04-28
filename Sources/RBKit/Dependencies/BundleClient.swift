import Foundation

import Dependencies
import DependenciesMacros

// MARK: - BundleClient

@DependencyClient
public struct BundleClient {
  public var main: () -> Bundle = { .init() }
  public var create: (_ url: URL) -> Bundle?
  public var bundleIdentifier: (_ bundle: Bundle) -> String?
  public var infoDictionary: (_ bundle: Bundle) -> [String: Any]?
  public var object: (_ inBundle: Bundle, _ forInfoDictionaryKey: String) -> Any?
}

// MARK: DependencyKey

extension BundleClient: DependencyKey {
  public static let liveValue = BundleClient(
    main: { .main },
    create: { Bundle(url: $0) },
    bundleIdentifier: { $0.bundleIdentifier },
    infoDictionary: { $0.infoDictionary },
    object: { $0.object(forInfoDictionaryKey: $1) }
  )
  public static let testValue = BundleClient()
}

extension DependencyValues {
  public var bundleClient: BundleClient {
    get { self[BundleClient.self] }
    set { self[BundleClient.self] = newValue }
  }
}
