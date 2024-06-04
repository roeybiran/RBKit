import Dependencies
import DependenciesMacros
import UserNotifications

// MARK: - UserNotificationCenterClient

@DependencyClient
public struct UserNotificationCenterClient {
  public var requestAuthorization: (_ options: UNAuthorizationOptions) async throws -> Bool
  public var add: (_ request: UNNotificationRequest) async throws -> Void
}

// MARK: DependencyKey

extension UserNotificationCenterClient: DependencyKey {
  public static let liveValue = UserNotificationCenterClient(
    requestAuthorization: UNUserNotificationCenter.current().requestAuthorization(options:),
    add: UNUserNotificationCenter.current().add)

  public static let testValue = UserNotificationCenterClient()
}

extension DependencyValues {
  public var userNotificationsClient: UserNotificationCenterClient {
    get { self[UserNotificationCenterClient.self] }
    set { self[UserNotificationCenterClient.self] = newValue }
  }
}
