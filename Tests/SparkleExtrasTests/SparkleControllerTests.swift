import AppKit
import Dependencies
import Sparkle
import Testing
@testable import SparkleExtras

// MARK: - SparkleControllerTests

@MainActor
struct SparkleControllerTests {
  @Test
  func `init(), should start with no available updates`() {
    let sut = SparkleController()
    #expect(!sut.areUpdatesAvailable)
  }

  @Test
  func `supportsGentleScheduledUpdateReminders, should return true`() {
    let sut = SparkleController()
    #expect(sut.supportsGentleScheduledUpdateReminders)
  }

  @Test
  func `standardUserDriverShouldHandleShowingScheduledUpdate(_:andInImmediateFocus:), should follow immediate focus`() {
    let sut = SparkleController()
    #expect(sut.standardUserDriverShouldHandleShowingScheduledUpdate(.empty(), andInImmediateFocus: true))
    #expect(!sut.standardUserDriverShouldHandleShowingScheduledUpdate(.empty(), andInImmediateFocus: false))
  }

  @Test
  func `updater(_:didFindValidUpdate:), should set available updates and post notification`() throws {
    let center = Center()
    let updaterController = UpdaterMock()

    let sut = withDependencies { d in
      d.notificationCenter = center
    } operation: {
      SparkleController()
    }
    sut.updaterController = updaterController

    #expect(!sut.areUpdatesAvailable)
    sut.updater(updaterController.updater, didFindValidUpdate: .empty())
    #expect(sut.areUpdatesAvailable)
    #expect(center.didCall)
    #expect(center.notification?.name == .areUpdatesAvailable)
    #expect(try #require(center.notification?.object as? Bool) == true)
  }

  @Test
  func `updaterDidNotFindUpdate(_:), should clear available updates and post notification`() throws {
    let center = Center()
    let updaterController = UpdaterMock()

    let sut = withDependencies { d in
      d.notificationCenter = center
    } operation: {
      SparkleController()
    }
    sut.updaterController = updaterController

    sut.areUpdatesAvailable = true
    #expect(sut.areUpdatesAvailable)

    sut.updaterDidNotFindUpdate(updaterController.updater)
    #expect(!sut.areUpdatesAvailable)

    #expect(center.didCall)
    #expect(center.notification?.name == .areUpdatesAvailable)
    #expect(try #require(center.notification?.object as? Bool) == false)
  }

  @Test
  func `checkForUpdates(_:), should forward to the updater controller`() {
    let sut = SparkleController()
    let mock = UpdaterMock()
    sut.updaterController = mock
    #expect(!mock.called)
    sut.checkForUpdates(nil)
    #expect(mock.called)
  }

  @Test
  func `validateMenuItem(_:), should update the menu item title`() {
    let sut = SparkleController()
    let menuItem = NSMenuItem(title: "", action: #selector(SparkleController.checkForUpdates(_:)), keyEquivalent: "")
    #expect(sut.validateMenuItem(menuItem))
    #expect(menuItem.title == .defaultMenuItemTitle)
    #expect(menuItem.image == nil)
    sut.areUpdatesAvailable = true
    #expect(sut.validateMenuItem(menuItem))
    #expect(menuItem.title == .updatesAvailableMenuItemTitle)
    #expect(menuItem.image == nil)
  }
}

// MARK: - UpdaterMock

final class UpdaterMock: SPUStandardUpdaterController {

  // MARK: Lifecycle

  init() {
    super.init(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
  }

  // MARK: Internal

  var called = false

  override func checkForUpdates(_: Any?) {
    called = true
  }

}

// MARK: - Center

// Test-only notification center subclass stays on the main actor but crosses a Sendable dependency boundary.
// swiftlint:disable:next no_unchecked_sendable
final class Center: NotificationCenter, @unchecked Sendable {
  var notification: Notification?
  var didCall = false

  override func post(_ notification: Notification) {
    self.notification = notification
    didCall = true
  }
}
