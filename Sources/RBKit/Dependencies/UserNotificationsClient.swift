import Dependencies
import UserNotifications

// MARK: - UserNotificationsClient

public struct UserNotificationsClient {
  public var requestAuthorization: (_ options: UNAuthorizationOptions) async throws -> Bool
  public var add: (_ request: UNNotificationRequest) async throws -> Void
}

extension UserNotificationsClient: DependencyKey {
  public static let liveValue: UserNotificationsClient = {
    let center = UNUserNotificationCenter.current()
    return Self(
      requestAuthorization: center.requestAuthorization,
      add: center.add
    )
  }()

  public static let testValue = UserNotificationsClient(
    requestAuthorization: unimplemented("requestAuthorization", placeholder: true),
    add: unimplemented("UserNotificationsClient.add")
  )
}

extension DependencyValues {
  public var userNotificationsClient: UserNotificationsClient {
    get { self[UserNotificationsClient.self] }
    set { self[UserNotificationsClient.self] = newValue }
  }
}
