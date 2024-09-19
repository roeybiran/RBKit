import Dependencies
import DependenciesMacros
import UserNotifications

// MARK: - UserNotificationCenterClient

@DependencyClient
public struct UserNotificationCenterClient: Sendable {
  public var requestAuthorization: @Sendable (_ options: UNAuthorizationOptions) async throws -> Bool
  public var add: @Sendable (_ request: UNNotificationRequest) async throws -> Void
}

// MARK: DependencyKey

extension UserNotificationCenterClient: DependencyKey {
  public static let liveValue = UserNotificationCenterClient(
    requestAuthorization: {
      try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
    },
    add: {
      try await UNUserNotificationCenter.current().add($0)
    }
  )

  public static let testValue = UserNotificationCenterClient()
}

extension DependencyValues {
  public var userNotificationsClient: UserNotificationCenterClient {
    get { self[UserNotificationCenterClient.self] }
    set { self[UserNotificationCenterClient.self] = newValue }
  }
}
