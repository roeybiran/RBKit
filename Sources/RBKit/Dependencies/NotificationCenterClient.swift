import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NotificationCenterClient

@DependencyClient
public struct NotificationCenterClient {
  public var notifications: (_ name: Notification.Name, _ object: AnyObject?) -> NotificationCenter.Notifications = { NotificationCenter().notifications(named: $0, object: $1) }
}

// MARK: DependencyKey

extension NotificationCenterClient: DependencyKey {
  public static let liveValue = NotificationCenterClient(
    notifications: { NotificationCenter.default.notifications(named: $0, object: $1) }
  )
  public static let testValue = NotificationCenterClient()
}

extension DependencyValues {
  public var notificationCenterClient: NotificationCenterClient {
    get { self[NotificationCenterClient.self] }
    set { self[NotificationCenterClient.self] = newValue }
  }
}
