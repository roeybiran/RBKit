import Dependencies
import DependenciesMacros
import RBKit

// MARK: - OnboardingClient

@DependencyClient
nonisolated public struct OnboardingClient: Sendable {
  public var getIsOnboarded: @Sendable () -> Bool = { false }
  public var setIsOnboarded: @Sendable () -> Void
}

// MARK: DependencyKey

nonisolated extension OnboardingClient: DependencyKey {
  public static let liveValue: Self = {
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    return Self(
      getIsOnboarded: { userDefaultsClient.bool(forKey: .DID_ONBOARD) },
      setIsOnboarded: { userDefaultsClient.setBool(value: true, forKey: .DID_ONBOARD) },
    )
  }()

  public static let testValue = Self()
}

nonisolated extension DependencyValues {
  public var onboardingClient: OnboardingClient {
    get { self[OnboardingClient.self] }
    set { self[OnboardingClient.self] = newValue }
  }
}
