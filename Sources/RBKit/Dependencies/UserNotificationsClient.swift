import Dependencies
import UserNotifications

// MARK: - UserNotificationsClient

public struct UserNotificationsClient {
  public var add: (_ title: String, _ body: String) -> Void
}

extension UserNotificationsClient: DependencyKey {
  public static let liveValue: UserNotificationsClient = {
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    return UserNotificationsClient { _, _ in
      center.requestAuthorization { granted, _ in
        if granted {
          center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
        }
      }
    }
  }()
}

extension DependencyValues {
  public var userNotificationsClient: UserNotificationsClient {
    get { self[UserNotificationsClient.self] }
    set { self[UserNotificationsClient.self] = newValue }
  }
}
