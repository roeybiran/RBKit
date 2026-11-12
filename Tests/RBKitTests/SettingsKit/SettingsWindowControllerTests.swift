import AppKit
import Dependencies
import Sharing
import SwiftUI
import Testing
@testable import RBKit

// MARK: - SettingsWindowControllerTests

@MainActor
@Suite(.serialized)
struct SettingsWindowControllerTests {
  @Test
  func `SettingsWindowController.init(_:), should store the panes`() {
    let pane = makeTestPane("Test Pane", identifier: "test-pane")
    let viewController = pane.viewController
    let controller = SettingsWindowController([pane])

    #expect(controller.panes.count == 1)
    #expect(controller.panes[0].label == "Test Pane")
    #expect(controller.panes[0].viewController === viewController)
  }

  @Test
  func `loadWindow(), with one pane, should show the pane without a sidebar`() {
    let pane = makeTestPane("Test Pane", identifier: "test-pane")
    let viewController = pane.viewController
    let controller = SettingsWindowController([pane])

    _ = controller.window

    #expect(controller.window != nil)
    #expect(controller.window?.styleMask.contains([.titled, .closable, .resizable]) == true)
    #expect(controller.window?.autorecalculatesKeyViewLoop == true)
    #expect(controller.windowFrameAutosaveName == SettingsWindowController.frameAutosaveName)
    #expect(controller.contentViewController === controller.detailViewController)
    #expect(controller.sidebarViewController == nil)
    #expect(controller.window?.toolbar == nil)
    #expect(controller.detailViewController.currentViewController === viewController)
  }

  @Test
  func `loadWindow(), with more than one pane, should configure a sidebar and toolbar`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 1

    let pane1 = makeTestPane("Pane 1", identifier: "pane-1")
    let viewController1 = pane1.viewController
    let pane2 = makeTestPane("Pane 2", identifier: "pane-2")
    let viewController2 = pane2.viewController

    let controller = SettingsWindowController([pane1, pane2])

    _ = controller.window

    let splitViewController = controller.contentViewController as? NSSplitViewController
    #expect(splitViewController?.splitViewItems.count == 2)
    #expect(splitViewController?.splitViewItems.first?.behavior == .sidebar)
    #expect(controller.window?.toolbar != nil)
    #expect(controller.window?.styleMask.contains(.fullSizeContentView) == true)
    #expect(controller.selectedPaneIndex == storedSelectedTabIndex)
    #expect(controller.detailViewController.currentViewController === viewController2)
    #expect(controller.sidebarViewController?.tableView.numberOfRows == 2)
    #expect(controller.sidebarViewController?.tableView.selectedRow == 1)
    #expect(controller.window?.title == "Pane 2")
  }

  @Test
  func `loadWindow(), with invalid last selected tab index, should select the first pane`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 2

    let pane1 = makeTestPane("Pane 1", identifier: "pane-1")
    let viewController1 = pane1.viewController
    let pane2 = makeTestPane("Pane 2", identifier: "pane-2")
    let viewController2 = pane2.viewController

    let controller = SettingsWindowController([pane1, pane2])
    _ = controller.window
    #expect(controller.selectedPaneIndex == 0)
    #expect(controller.detailViewController.currentViewController === viewController1)
    #expect(storedSelectedTabIndex == 0)
  }

  @Test
  func `openPane(identifier:), should select the pane and support back and forward`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 0

    let panes = (0..<3).map { makeTestPane("Pane \($0)", identifier: "pane-\($0)") }
    let controller = SettingsWindowController(panes)
    _ = controller.window

    #expect(!controller.canGoBack)
    controller.openPane(identifier: "pane-2")
    #expect(controller.selectedPaneIndex == 2)
    #expect(controller.window?.title == "Pane 2")
    #expect(storedSelectedTabIndex == 2)
    #expect(controller.sidebarViewController?.tableView.selectedRow == 2)

    controller.openPane(identifier: "pane-1")
    controller.goBack(nil)
    #expect(controller.selectedPaneIndex == 2)
    #expect(controller.canGoForward)
    controller.goBack(nil)
    #expect(controller.selectedPaneIndex == 0)
    #expect(!controller.canGoBack)
    controller.goForward(nil)
    #expect(controller.selectedPaneIndex == 2)

    controller.openPane(identifier: "pane-0")
    #expect(!controller.canGoForward)
  }

  @Test
  func `isSettingsWindowFloating observation, with true, should set the window level to floating`() async {
    @Shared(.isSettingsWindowFloating) var isSettingsWindowFloating = false

    let pane = makeTestPane("Pane 1", identifier: "pane-1")
    let viewController = pane.viewController
    let controller = SettingsWindowController([pane])

    #expect(controller.window?.level == .normal)

    _ = controller.window
    $isSettingsWindowFloating.withLock {
      $0 = true
    }

    for _ in 1...10 {
      if controller.window?.level == .floating { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
    }

    #expect(controller.window?.level == .floating)
  }

  @Test
  func `isSettingsWindowFloating observation, with false, should set the window level to normal`() async {
    @Shared(.isSettingsWindowFloating) var isSettingsWindowFloating = true

    let pane = makeTestPane("Pane 1", identifier: "pane-1")
    let viewController = pane.viewController
    let controller = SettingsWindowController([pane])

    _ = controller.window

    #expect(controller.window?.level == .floating)

    $isSettingsWindowFloating.withLock {
      $0 = false
    }

    for _ in 1...10 {
      if controller.window?.level == .normal { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
    }

    #expect(controller.window?.level == .normal)
  }

  @Test
  func `selecting in the sidebar, should show and persist the selected pane`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 0

    let pane1 = makeTestPane("Pane 1", identifier: "pane-1")
    let viewController1 = pane1.viewController
    let pane2 = makeTestPane("Pane 2", identifier: "pane-2")
    let viewController2 = pane2.viewController

    let controller = SettingsWindowController([pane1, pane2])
    _ = controller.window

    controller.sidebarViewController?.tableView.selectRowIndexes([1], byExtendingSelection: false)

    #expect(controller.window?.title == "Pane 2")
    #expect(controller.detailViewController.currentViewController === viewController2)
    #expect(storedSelectedTabIndex == 1)
    #expect(controller.canGoBack)
  }

  @Test
  func `windowDidLoad(), with one pane, should use the generic window title`() async {
    let pane1 = makeTestPane("Pane 1", identifier: "pane-1")
    let viewController1 = pane1.viewController
    let controller = SettingsWindowController([pane1])
    _ = controller.window

    _ = controller.window
    for _ in 1...10 {
      if (controller.window?.title ?? "") == "\(Bundle.main.appName) Settings" { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
    }
    #expect((controller.window?.title ?? "") == "\(Bundle.main.appName) Settings")
  }

  @Test
  func `doCommand(by:), with cancel selector, should close`() {
    class Sub: SettingsWindowController {
      var closed = false
      override func close() {
        closed = true
      }
    }

    let pane = makeTestPane("Test Pane", identifier: "test-pane")
    let viewController = pane.viewController
    let controller = Sub([pane])

    controller.doCommand(by: #selector(NSSavePanel.cancel(_:)))

    #expect(controller.closed)
  }
}

// MARK: - UserDefaults + @unchecked @retroactive Sendable

extension UserDefaults: @unchecked @retroactive Sendable { }

let TEST_SLEEP_DURATION = Duration.seconds(0.02)
