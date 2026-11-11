import AppKit
import Testing
@testable import RBKit

@MainActor
struct PaneTests {
  @Test
  func `Pane.init(_:identifier:systemImage:viewController:), should store values`() {
    let viewController = NSViewController()
    let pane = Pane("Test Pane", identifier: "test-pane", systemImage: "gearshape", viewController: viewController)

    #expect(pane.label == "Test Pane")
    #expect(pane.systemImage == "gearshape")
    #expect(pane.viewController === viewController)
  }

  @Test
  func `NSTabViewItem.init(pane:), should reflect pane values`() {
    let viewController = NSViewController()
    let pane = Pane("Test Pane", identifier: "test-pane", systemImage: "gearshape", viewController: viewController)
    let tabViewItem = NSTabViewItem(pane: pane)

    #expect(tabViewItem.label == "Test Pane")
    #expect(tabViewItem.image != nil)
    #expect(tabViewItem.viewController === viewController)
  }

}
