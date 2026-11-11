import AppKit
import Dependencies
import RBKit
import Sparkle

// MARK: - SparkleController

final class SparkleController: NSObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate, NSMenuItemValidation {

  // MARK: Lifecycle

  override init() {
    super.init()
  }

  // MARK: Internal

  static let shared = SparkleController()

  @Dependency(\.notificationCenter) var notificationCenterClient

  lazy var updaterController = SPUStandardUpdaterController(
    startingUpdater: true,
    updaterDelegate: self,
    userDriverDelegate: self,
  )

  var areUpdatesAvailable = false

  var supportsGentleScheduledUpdateReminders: Bool {
    true
  }

  func stream() -> AsyncStream<Bool> {
    AsyncStream { [notificationCenterClient] cont in
      Task {
        for await value in notificationCenterClient
          .notifications(named: .areUpdatesAvailable, object: nil)
          .compactMap({ $0.object as? Bool })
        {
          cont.yield(value)
        }
      }
    }
  }

  @MainActor
  @objc
  func checkForUpdates(_ sender: Any?) {
    updaterController.checkForUpdates(sender)
  }

  func standardUserDriverShouldHandleShowingScheduledUpdate(
    _: SUAppcastItem,
    andInImmediateFocus immediateFocus: Bool,
  ) -> Bool {
    immediateFocus
  }

  func updater(_: SPUUpdater, didFindValidUpdate _: SUAppcastItem) {
    areUpdatesAvailable = true
    notificationCenterClient.post(Notification(name: .areUpdatesAvailable, object: true))
  }

  func updaterDidNotFindUpdate(_: SPUUpdater) {
    areUpdatesAvailable = false
    notificationCenterClient.post(Notification(name: .areUpdatesAvailable, object: false))
  }

  func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    if menuItem.action == #selector(checkForUpdates(_:)) {
      menuItem.title = areUpdatesAvailable ? .updatesAvailableMenuItemTitle : .defaultMenuItemTitle
    }
    return true
  }
}
