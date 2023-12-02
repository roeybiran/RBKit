import Dependencies
import Foundation

// MARK: - NotificationCenterClient

public struct NotificationCenterClient {
  public var notifications: (_ name: Notification.Name, _ object: AnyObject?) -> AsyncStream<Notification>
}

// MARK: DependencyKey

extension NotificationCenterClient: DependencyKey {
  public static let liveValue: NotificationCenterClient = Self(
    notifications: { name, object in
      AsyncStream<Notification> { continuation in
        let cancellable = NotificationCenter
          .default
          .publisher(for: name, object: object)
          .sink {
            continuation.yield($0)
          }

        continuation.onTermination = { _ in
          cancellable.cancel()
        }
      }
    })

  public static let testValue = NotificationCenterClient(notifications: unimplemented("NotificationCenterClient.notifications"))
}

extension DependencyValues {
  public var notificationCenterClient: NotificationCenterClient {
    get { self[NotificationCenterClient.self] }
    set { self[NotificationCenterClient.self] = newValue }
  }
}
