import Dependencies
import DependenciesMacros
import Foundation

// MARK: - BundleClient

@DependencyClient
public struct BundleClient {
  public var bundleIdentifier: () -> String?
}

// MARK: DependencyKey

extension BundleClient: DependencyKey {
  public static let liveValue = BundleClient(bundleIdentifier: { Bundle.main.bundleIdentifier })
  public static let testValue = BundleClient()
}

extension DependencyValues {
  public var bundleClient: BundleClient {
    get { self[BundleClient.self] }
    set { self[BundleClient.self] = newValue }
  }
}
