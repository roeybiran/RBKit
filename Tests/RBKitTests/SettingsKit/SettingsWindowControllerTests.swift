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
    let controller = SettingsWindowController([makeTestPane("Test Pane", identifier: "test-pane")])

    #expect(controller.model.panes.count == 1)
    #expect(controller.model.panes[0].label == "Test Pane")
  }

  @Test
  func `loadWindow(), should host the SwiftUI settings view in a resizable window`() {
    let controller = SettingsWindowController([makeTestPane("Test Pane", identifier: "test-pane")])

    _ = controller.window

    #expect(controller.window?.styleMask.contains([.titled, .closable, .resizable, .fullSizeContentView]) == true)
    #expect(controller.window?.autorecalculatesKeyViewLoop == true)
    #expect(controller.windowFrameAutosaveName == SettingsWindowController.frameAutosaveName)
    #expect(controller.contentViewController != nil)
  }

  @Test
  func `loadWindow(), with more than one pane, should restore the stored pane`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 1

    let controller = SettingsWindowController([
      makeTestPane("Pane 1", identifier: "pane-1"),
      makeTestPane("Pane 2", identifier: "pane-2"),
    ])

    _ = controller.window

    #expect(controller.model.selectedIndex == 1)
    #expect(controller.window?.title == "Pane 2")
    #expect(!controller.model.canGoBack)
  }

  @Test
  func `loadWindow(), with invalid last selected tab index, should select the first pane`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 2

    let controller = SettingsWindowController([
      makeTestPane("Pane 1", identifier: "pane-1"),
      makeTestPane("Pane 2", identifier: "pane-2"),
    ])
    _ = controller.window

    #expect(controller.model.selectedIndex == 0)
    #expect(controller.window?.title == "Pane 1")
    #expect(storedSelectedTabIndex == 0)
  }

  @Test
  func `openPane(identifier:), should select, title, and persist the pane`() {
    @Shared(.settingsWindowLastTabIndex) var storedSelectedTabIndex = 0

    let controller = SettingsWindowController((0..<3).map { makeTestPane("Pane \($0)", identifier: "pane-\($0)") })
    _ = controller.window

    controller.openPane(identifier: "pane-2")
    #expect(controller.model.selectedIndex == 2)
    #expect(controller.window?.title == "Pane 2")
    #expect(storedSelectedTabIndex == 2)

    controller.goBack(nil)
    #expect(controller.window?.title == "Pane 0")
    controller.goForward(nil)
    #expect(controller.window?.title == "Pane 2")
  }

  @Test
  func `isSettingsWindowFloating observation, with true, should set the window level to floating`() async {
    @Shared(.isSettingsWindowFloating) var isSettingsWindowFloating = false

    let pane = makeTestPane("Pane 1", identifier: "pane-1")
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
  func `windowDidLoad(), with one pane, should use the generic window title`() async {
    let pane1 = makeTestPane("Pane 1", identifier: "pane-1")
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
    let controller = Sub([pane])

    controller.doCommand(by: #selector(NSSavePanel.cancel(_:)))

    #expect(controller.closed)
  }
}

// MARK: - UserDefaults + @unchecked @retroactive Sendable

extension UserDefaults: @unchecked @retroactive Sendable { }

let TEST_SLEEP_DURATION = Duration.seconds(0.02)
