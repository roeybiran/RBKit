import Foundation

import Dependencies
import DependenciesMacros

// MARK: - BundleClient

@DependencyClient
public struct BundleClient: Sendable {
  public var main: @Sendable () -> Bundle = { .init() }
  public var create: @Sendable (_ url: URL) -> Bundle?
  public var bundleIdentifier: @Sendable (_ bundle: Bundle) -> String?
  public var infoDictionary: @Sendable (_ bundle: Bundle) -> [String: Any]?
  public var object: @Sendable (_ inBundle: Bundle, _ forInfoDictionaryKey: String) -> Any?
}

// MARK: DependencyKey

extension BundleClient: DependencyKey {
  public static let liveValue = BundleClient(
    main: { .main },
    create: { Bundle(url: $0) },
    bundleIdentifier: { $0.bundleIdentifier },
    infoDictionary: { $0.infoDictionary },
    object: { $0.object(forInfoDictionaryKey: $1) })
  public static let testValue = BundleClient()
}

extension DependencyValues {
  public var bundleClient: BundleClient {
    get { self[BundleClient.self] }
    set { self[BundleClient.self] = newValue }
  }
}
