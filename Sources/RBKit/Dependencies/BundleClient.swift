import Dependencies
import Foundation

// MARK: - BundleClient

public struct BundleClient {
  public var bundleIdentifier: () -> String?
}

// MARK: DependencyKey

extension BundleClient: DependencyKey {
  public static let liveValue = BundleClient(
    bundleIdentifier: { Bundle.main.bundleIdentifier })

  #if DEBUG
  public static let testValue = BundleClient(
    bundleIdentifier: unimplemented("BundleClient.bundleIdentifier"))

  public static let placeholder = BundleClient(
    bundleIdentifier: { "BUNDLE_ID" })
  #endif
}

extension DependencyValues {
  public var bundleClient: BundleClient {
    get { self[BundleClient.self] }
    set { self[BundleClient.self] = newValue }
  }
}
