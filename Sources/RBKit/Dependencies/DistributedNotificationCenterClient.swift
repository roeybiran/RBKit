import Dependencies
import DependenciesMacros
import Foundation

// MARK: - DistributedNotificationCenterClient

@DependencyClient
public struct DistributedNotificationCenterClient: Sendable {
  public var notifications: @Sendable (_ named: Notification.Name) -> NotificationCenter.Notifications = { named in
    NotificationCenter().notifications(named: named, object: nil)
  }
}

// MARK: DependencyKey

extension DistributedNotificationCenterClient: DependencyKey {
  public static let liveValue = Self(
    notifications: { named in
      DistributedNotificationCenter.default().notifications(named: named, object: nil)
    }
  )

  public static let testValue = Self(
    notifications: { named in
      NotificationCenter().notifications(named: named, object: nil)
    }
  )
}

extension DependencyValues {
  public var distributedNotificationCenterClient: DistributedNotificationCenterClient {
    get { self[DistributedNotificationCenterClient.self] }
    set { self[DistributedNotificationCenterClient.self] = newValue }
  }
}
