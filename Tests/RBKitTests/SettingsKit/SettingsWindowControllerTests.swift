import AppKit
import Dependencies
import Sharing
import Testing
@testable import RBKit

// MARK: - SettingsWindowControllerTests

@MainActor
@Suite(.serialized)
struct SettingsWindowControllerTests {
  @Test
  func `SettingsWindowController.init(_:), should create one tab item`() {
    let viewController = NSViewController()
    let pane = Pane("Test Pane", identifier: "test-pane", systemImage: "gearshape", viewController: viewController)
    let controller = SettingsWindowController([pane])

    #expect(controller.tabViewItems.count == 1)
    #expect(controller.tabViewItems[0].label == "Test Pane")
    #expect(controller.tabViewItems[0].viewController == viewController)
    #expect(controller.tabViewItems[0].image != nil)
  }

  @Test
  func `loadWindow(), with one pane, should configure an unspecified tab style`() {
    let viewController = NSViewController()
    let pane = Pane("Test Pane", identifier: "test-pane", systemImage: "gearshape", viewController: viewController)
    let controller = SettingsWindowController([pane])

    _ = controller.window

    #expect(controller.window != nil)
    #expect(controller.window?.styleMask == [.titled, .closable])
    #expect(controller.window?.autorecalculatesKeyViewLoop == true)
    #expect(controller.windowFrameAutosaveName == "SettingsWindowController")
    let vc = controller.contentViewController as? NSTabViewController
    #expect(vc?.tabStyle == .unspecified)
    #expect(vc?.selectedTabViewItemIndex == 0)
  }

  @Test
  func `loadWindow(), with more than one pane, should configure a toolbar tab style`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 1

    let viewController1 = NSViewController()
    let pane1 = Pane("Pane 1", identifier: "pane-1", systemImage: "gearshape", viewController: viewController1)
    let viewController2 = NSViewController()
    let pane2 = Pane("Pane 2", identifier: "pane-2", systemImage: "star", viewController: viewController2)

    let controller = SettingsWindowController([pane1, pane2])

    _ = controller.window

    let contentVC = controller.contentViewController as? NSTabViewController

    #expect(contentVC?.tabStyle == .toolbar)
    #expect(contentVC?.selectedTabViewItemIndex == storedSelectedTabIndex)
    #expect(contentVC?.tabViewItems.count == 2)
    #expect(contentVC?.tabViewItems[0].label == "Pane 1")
    #expect(contentVC?.tabViewItems[0].image != nil)
    #expect(contentVC?.tabViewItems[1].label == "Pane 2")
    #expect(contentVC?.tabViewItems[1].image != nil)
  }

  @Test
  func `loadWindow(), with invalid last selected tab index, should select the first pane`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 2

    let viewController1 = NSViewController()
    let pane1 = Pane("Pane 1", identifier: "pane-1", systemImage: "gearshape", viewController: viewController1)
    let viewController2 = NSViewController()
    let pane2 = Pane("Pane 2", identifier: "pane-2", systemImage: "star", viewController: viewController2)

    let controller = SettingsWindowController([pane1, pane2])
    _ = controller.window
    let contentVC = controller.contentViewController as? NSTabViewController
    #expect(contentVC?.selectedTabViewItemIndex == 0)
    #expect(storedSelectedTabIndex == 2)
  }

  @Test
  func `isSettingsWindowFloating observation, with true, should set the window level to floating`() async {
    @Shared(.isSettingsWindowFloating) var isSettingsWindowFloating = false

    let viewController = NSViewController()
    let pane = Pane("Pane 1", identifier: "pane-1", systemImage: "gearshape", viewController: viewController)
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

    let viewController = NSViewController()
    let pane = Pane("Pane 1", identifier: "pane-1", systemImage: "gearshape", viewController: viewController)
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
  func `selectedTabViewItemIndex observation, should persist the selected tab index`() async {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 1

    let viewController1 = NSViewController()
    let pane1 = Pane("Pane 1", identifier: "pane-1", systemImage: "gearshape", viewController: viewController1)
    let viewController2 = NSViewController()
    let pane2 = Pane("Pane 2", identifier: "pane-2", systemImage: "star", viewController: viewController2)

    let controller = SettingsWindowController([pane1, pane2])

    _ = controller.window

    for _ in 1...10 {
      if controller.window?.title == "Pane 2" { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
    }

    #expect(controller.window?.title == "Pane 2")
    #expect(storedSelectedTabIndex == 1)
  }

  @Test
  func `windowDidLoad(), with one pane, should use the generic window title`() async {
    let viewController1 = NSViewController()
    let pane1 = Pane("Pane 1", identifier: "pane-1", systemImage: "gearshape", viewController: viewController1)
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

    let viewController = NSViewController()
    let pane = Pane("Test Pane", identifier: "test-pane", systemImage: "gearshape", viewController: viewController)
    let controller = Sub([pane])

    controller.doCommand(by: #selector(NSSavePanel.cancel(_:)))

    #expect(controller.closed)
  }
}

// MARK: - UserDefaults + @unchecked @retroactive Sendable

extension UserDefaults: @unchecked @retroactive Sendable { }

let TEST_SLEEP_DURATION = Duration.seconds(0.02)
