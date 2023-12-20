import Dependencies
import DependenciesMacros
import UserNotifications

// MARK: - UserNotificationsClient

@DependencyClient
public struct UserNotificationsClient {
  public var requestAuthorization: (_ options: UNAuthorizationOptions) async throws -> Bool
  public var add: (_ request: UNNotificationRequest) async throws -> Void
}

extension UserNotificationsClient: DependencyKey {
  public static let liveValue = UserNotificationsClient(
    requestAuthorization: UNUserNotificationCenter.current().requestAuthorization(options:),
    add: UNUserNotificationCenter.current().add
  )

  public static let testValue = UserNotificationsClient()
}

extension DependencyValues {
  public var userNotificationsClient: UserNotificationsClient {
    get { self[UserNotificationsClient.self] }
    set { self[UserNotificationsClient.self] = newValue }
  }
}
