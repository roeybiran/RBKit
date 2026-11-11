import AppKit
import Testing
@testable import RBKit

@MainActor
struct MenuBarExtraSettingViewTests {
  @Test
  func `init should read visibility from status item`() {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem.button?.title = "Test"
    defer {
      NSStatusBar.system.removeStatusItem(statusItem)
    }

    statusItem.isVisible = false

    let viewModel = MenuBarExtraSettingViewModel(statusItem: statusItem)

    #expect(!viewModel.isVisible)
  }

  @Test
  func `checkboxClicked should update state and status item visibility`() {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem.button?.title = "Test"
    defer {
      NSStatusBar.system.removeStatusItem(statusItem)
    }

    let viewModel = MenuBarExtraSettingViewModel(statusItem: statusItem)

    viewModel.checkboxClicked(isOn: false)
    #expect(!viewModel.isVisible)
    #expect(!statusItem.isVisible)

    viewModel.checkboxClicked(isOn: true)
    #expect(viewModel.isVisible)
    #expect(statusItem.isVisible)
  }
}
