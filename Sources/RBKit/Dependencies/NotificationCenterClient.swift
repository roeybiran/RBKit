import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NotificationCenterClient

@DependencyClient
public struct NotificationCenterClient {
  public var post: (_ notification: Notification) -> Void
  public var notifications: (_ named: Notification.Name, _ object: AnyObject?) -> NotificationCenter
    .Notifications = { NotificationCenter().notifications(
      named: $0,
      object: $1) }
}

// MARK: DependencyKey

extension NotificationCenterClient: DependencyKey {
  public static let liveValue: Self = {
    let instance = NotificationCenter.default
    return Self(
      post: instance.post,
      notifications: instance.notifications)
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var notificationCenterClient: NotificationCenterClient {
    get { self[NotificationCenterClient.self] }
    set { self[NotificationCenterClient.self] = newValue }
  }
}
