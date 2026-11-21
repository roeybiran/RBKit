import AppKit
import Testing

@testable import RBKit

@Suite(.serialized)
@MainActor
struct NSMenuItemStandardMenuTests {
  @Test
  func `init with builder, should attach submenu children`() throws {
    let child1 = NSMenuItem("Child 1")
    let child2 = NSMenuItem("Child 2")
    let menuItem = NSMenuItem("Parent") {
      child1
      child2
    }
    let submenu = try #require(menuItem.submenu)

    #expect(submenu.title == "Parent")
    #expect(submenu.items.count == 2)
    #expect(submenu.items[0] === child1)
    #expect(submenu.items[1] === child2)
  }

  @Test
  func `init with empty builder, should not create submenu`() {
    let menuItem = NSMenuItem("Parent") { }

    #expect(menuItem.submenu == nil)
  }

  @Test
  func `init with default selector and target, should keep action and target nil`() {
    let menuItem = NSMenuItem("Plain")

    #expect(menuItem.action == nil)
    #expect(menuItem.target == nil)
    #expect(menuItem.submenu == nil)
  }

  @Test
  func `init with selector and target, should assign selector and target`() {
    let selector = #selector(NSApplication.terminate(_:))
    let target = NSApplication.shared
    let menuItem = NSMenuItem("Terminate", selector: selector, target: target, keyEquivalent: "q")

    #expect(menuItem.action == selector)
    #expect(menuItem.target === target)
    #expect(menuItem.keyEquivalent == "q")
  }

  @Test
  func `servicesMenu(app:), should set servicesMenu on provided app`() throws {
    let app = NSApplication.shared
    let originalServicesMenu = app.servicesMenu
    defer { app.servicesMenu = originalServicesMenu }

    let menuItem = NSMenuItem.servicesMenu(app: app)
    let submenu = try #require(menuItem.submenu)

    #expect(menuItem.title == "Services")
    #expect(app.servicesMenu === submenu)
  }

  @Test
  func `windowMenu(app:), should include standard window items and set windowsMenu`() throws {
    let app = NSApplication.shared
    let originalWindowsMenu = app.windowsMenu
    defer { app.windowsMenu = originalWindowsMenu }

    let menuItem = NSMenuItem.windowMenu(app: app)
    let submenu = try #require(menuItem.submenu)
    let itemTitles = submenu.items.map(\.title)

    #expect(menuItem.title == "Window")
    #expect(submenu.items.count == 4)
    #expect(itemTitles == ["Minimize", "Zoom", "", "Bring All to Front"])
    #expect(submenu.items[0].action == #selector(NSWindow.performMiniaturize(_:)))
    #expect(submenu.items[1].action == #selector(NSWindow.performZoom(_:)))
    #expect(submenu.items[2].isSeparatorItem)
    #expect(submenu.items[3].action == #selector(NSApplication.arrangeInFront(_:)))
    #expect(app.windowsMenu === submenu)
  }

  @Test
  func `helpMenu(app:selector:target:), should include configured help item and set helpMenu`() throws {
    let app = NSApplication.shared
    let originalHelpMenu = app.helpMenu
    defer { app.helpMenu = originalHelpMenu }
    let selector = #selector(NSApplication.terminate(_:))

    let menuItem = NSMenuItem.helpMenu(
      app: app,
      selector: selector,
      target: app,
    )
    let submenu = try #require(menuItem.submenu)
    let helpMenuItem = try #require(submenu.items.first)

    #expect(menuItem.title == "Help")
    #expect(submenu.items.count == 1)
    #expect(helpMenuItem.title == "\(String.appName) Help")
    #expect(helpMenuItem.action == selector)
    #expect(helpMenuItem.target === app)
    #expect(app.helpMenu === submenu)
  }

  @Test
  func `settings(action:target:), should preserve metadata and apply provided action and target`() {
    let action = #selector(NSApplication.terminate(_:))
    let target = NSApplication.shared
    let menuItem = NSMenuItem.settings(action: action, target: target)

    #expect(menuItem.title == "Settings…")
    #expect(menuItem.keyEquivalent == ",")
    #expect(menuItem.action == action)
    #expect(menuItem.target === target)
  }

  @Test
  func `applicationMenu(settingsAction:settingsTarget:), should apply settings action and target`() throws {
    let action = #selector(NSApplication.terminate(_:))
    let target = NSApplication.shared
    let menuItem = NSMenuItem.applicationMenu(
      settingsAction: action,
      settingsTarget: target,
    )
    let submenu = try #require(menuItem.submenu)
    let settingsMenuItem = try #require(
      submenu.items.first(where: { $0.title == "Settings…" })
    )

    #expect(settingsMenuItem.action == action)
    #expect(settingsMenuItem.target === target)
  }

  @Test
  func `about(selector:target:), should support custom selector and default selector`() {
    let target = NSApplication.shared
    let customSelector = #selector(NSApplication.terminate(_:))

    let customMenuItem = NSMenuItem.about(selector: customSelector, target: target)
    let defaultMenuItem = NSMenuItem.about(target: target)

    #expect(customMenuItem.action == customSelector)
    #expect(customMenuItem.target === target)
    #expect(defaultMenuItem.action == #selector(NSApplication.orderFrontStandardAboutPanel(_:)))
    #expect(defaultMenuItem.target === target)
  }

  @Test
  func `app-level standard items, should include default images`() {
    #expect(NSMenuItem.about().image != nil)
    #expect(NSMenuItem.settings(action: nil, target: nil).image != nil)
    #expect(NSMenuItem.help().image != nil)
    #expect(NSMenuItem.quit.image != nil)
  }

  @Test
  func `standard static items, should preserve key metadata`() throws {
    #expect(NSMenuItem.close.title == "Close")
    #expect(NSMenuItem.close.action == #selector(NSWindow.performClose(_:)))
    #expect(NSMenuItem.close.keyEquivalent == "w")

    #expect(NSMenuItem.save.title == "Save…")
    #expect(NSMenuItem.revertToSaved.keyEquivalent == "r")
    #expect(NSMenuItem.find.action == #selector(NSTextView.performFindPanelAction(_:)))
    #expect(NSMenuItem.findAndReplace.action == #selector(NSTextView.performFindPanelAction(_:)))
    #expect(NSMenuItem.findNext.action == #selector(NSTextView.performFindPanelAction(_:)))
    #expect(NSMenuItem.findPrevious.action == #selector(NSTextView.performFindPanelAction(_:)))
    #expect(NSMenuItem.useSelectionForFind.action == #selector(NSTextView.performFindPanelAction(_:)))
    let writingDirectionAction = try #require(NSMenuItem.writingDirectionMenu.action)
    #expect(NSStringFromSelector(writingDirectionAction) == "submenuAction:")

    #expect(NSMenuItem.findNext.tag == NSTextFinder.Action.nextMatch.rawValue)
    #expect(NSMenuItem.bold.tag == Int(NSFontTraitMask.boldFontMask.rawValue))
    #expect(NSMenuItem.italic.tag == Int(NSFontTraitMask.italicFontMask.rawValue))
    #expect(NSMenuItem.bigger.tag == Int(NSFontAction.sizeUpFontAction.rawValue))
    #expect(NSMenuItem.smaller.tag == Int(NSFontAction.sizeDownFontAction.rawValue))
    #expect(NSMenuItem.showToolbar.keyEquivalentModifierMask == [.option, .command])
  }

  @Test
  func `standardMenuBar(settingsAction:settingsTarget:), should preserve top level order and settings action`() throws {
    let app = NSApplication.shared
    let originalServicesMenu = app.servicesMenu
    let originalWindowsMenu = app.windowsMenu
    let originalHelpMenu = app.helpMenu
    defer {
      app.servicesMenu = originalServicesMenu
      app.windowsMenu = originalWindowsMenu
      app.helpMenu = originalHelpMenu
    }

    let settingsAction = #selector(NSApplication.terminate(_:))
    let settingsTarget = NSApplication.shared
    let menuBar = NSMenu.standardMenuBar(
      settingsAction: settingsAction,
      settingsTarget: settingsTarget,
    )
    let titles = menuBar.items.map(\.title)

    #expect(titles == [
      String.appName,
      "File",
      "Edit",
      "Format",
      "View",
      "Window",
      "Help",
    ])

    let appMenu = try #require(menuBar.items.first?.submenu)
    let settingsMenuItem = try #require(
      appMenu.items.first(where: { $0.title == "Settings…" })
    )
    #expect(settingsMenuItem.action == settingsAction)
    #expect(settingsMenuItem.target === settingsTarget)
  }
}
