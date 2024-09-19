import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NotificationCenterClient

@DependencyClient
public struct NotificationCenterClient: Sendable {
  /// Adding and Removing Notification Observers
  public var addObserver: @Sendable (
    _ notificationCenter: NotificationCenter,
    _ observer: Any,
    _ selector: Selector,
    _ name: Notification.Name?,
    _ object: Any?) -> Void

  /// Posting notifications
  public var post: @Sendable (_ notification: Notification) -> Void

  /// Receiving Notifications as an Asynchronous Sequence
  public var notifications: @Sendable (_ named: Notification.Name, _ object: (any AnyObject & Sendable)?) -> AsyncStream<Notification> = { _, _ in
    .finished
  }
}

// MARK: DependencyKey

extension NotificationCenterClient: DependencyKey {
  public static let liveValue = Self(
    addObserver: { notificationCenter, observer, selector, name, object in
      notificationCenter.addObserver(observer, selector: selector, name: name, object: object)
    },
    post: { NotificationCenter.default.post($0) },
    notifications: { NotificationCenter.default.notifications(named: $0, object: $1).eraseToStream() }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var notificationCenterClient: NotificationCenterClient {
    get { self[NotificationCenterClient.self] }
    set { self[NotificationCenterClient.self] = newValue }
  }
}
