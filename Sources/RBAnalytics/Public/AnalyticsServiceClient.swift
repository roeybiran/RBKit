import Dependencies
import DependenciesMacros
import RBKit

// MARK: - AnalyticsServiceClient

@DependencyClient
public struct AnalyticsServiceClient: Sendable {
  public var start: @MainActor @Sendable (_ appID: String) -> Void = { _ in }
  public var getIsEnabled: @MainActor @Sendable () -> Bool = { false }
  public var setIsEnabled: @MainActor @Sendable (Bool) -> Void = { _ in }
  public var signal: @MainActor @Sendable (AnalyticsEvent) -> Void = { _ in }
}

// MARK: DependencyKey

extension AnalyticsServiceClient: DependencyKey {
  public static let liveValue = Self(
    start: { appID in
      AnalyticsService(appID: appID).start()
    },
    getIsEnabled: {
      AnalyticsService().isEnabled
    },
    setIsEnabled: {
      AnalyticsService().isEnabled = $0
    },
    signal: {
      AnalyticsService().signal($0)
    },
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var analyticsServiceClient: AnalyticsServiceClient {
    get { self[AnalyticsServiceClient.self] }
    set { self[AnalyticsServiceClient.self] = newValue }
  }
}
