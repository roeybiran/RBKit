import AppKit
import Testing
@testable import SparkleExtras

@MainActor
struct CheckForUpdatesMenuItemTests {
  @Test
  func `CheckForUpdates(), should configure the menu item`() throws {
    let sut = NSMenuItem.CheckForUpdates()

    #expect(sut.title == .defaultMenuItemTitle)
    #expect(sut.action == #selector(SparkleController.checkForUpdates(_:)))
    #expect(try #require(sut.target as? SparkleController) === SparkleController.shared)
    #expect(sut.keyEquivalent.isEmpty)
  }
}
