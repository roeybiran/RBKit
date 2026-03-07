import AppKit
import Testing

@testable import RBKit

@Suite(.serialized)
@MainActor
struct `NSMenuItem standard menu Tests` {
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
  func `init with empty builder, should create empty submenu`() throws {
    let menuItem = NSMenuItem("Parent") {
    }
    let submenu = try #require(menuItem.submenu)

    #expect(submenu.title == "Parent")
    #expect(submenu.items.isEmpty)
  }

  @Test
  func `withChildren, should return self and replace submenu items`() throws {
    let menuItem = NSMenuItem("Parent") {
    }
    let child1 = NSMenuItem("Child 1")
    let child2 = NSMenuItem("Child 2")

    let returned = menuItem.withChildren {
      child1
    }
    var submenu = try #require(menuItem.submenu)

    #expect(returned === menuItem)
    #expect(submenu.items.count == 1)
    #expect(submenu.items.first === child1)

    _ = menuItem.withChildren {
      child2
    }
    submenu = try #require(menuItem.submenu)

    #expect(submenu.items.count == 1)
    #expect(submenu.items.first === child2)
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

    #expect(menuItem.title == "Window")
    #expect(submenu.items.count == 4)
    #expect(submenu.items[0] === NSMenuItem.minimize)
    #expect(submenu.items[1] === NSMenuItem.zoom)
    #expect(submenu.items[2].isSeparatorItem)
    #expect(submenu.items[3] === NSMenuItem.bringAllToFront)
    #expect(app.windowsMenu === submenu)
  }

  @Test
  func `helpMenu(app:), should include standard help item and set helpMenu`() throws {
    let app = NSApplication.shared
    let originalHelpMenu = app.helpMenu
    defer { app.helpMenu = originalHelpMenu }

    let menuItem = NSMenuItem.helpMenu(app: app)
    let submenu = try #require(menuItem.submenu)

    #expect(menuItem.title == "Help")
    #expect(submenu.items.count == 1)
    #expect(submenu.items.first === NSMenuItem.help)
    #expect(app.helpMenu === submenu)
  }

  @Test
  func `settings(action:), should preserve metadata and apply provided action`() throws {
    let action = #selector(NSApplication.terminate(_:))
    let menuItem = NSMenuItem.settings(action: action)

    #expect(menuItem.title == "Settings…")
    #expect(menuItem.keyEquivalent == ",")
    #expect(menuItem.action == action)
  }

  @Test
  func `applicationMenu(settingsAction:), should apply settings action`() throws {
    let action = #selector(NSApplication.terminate(_:))
    let menuItem = NSMenuItem.applicationMenu(settingsAction: action)
    let submenu = try #require(menuItem.submenu)
    let settingsMenuItem = try #require(
      submenu.items.first(where: { $0.title == "Settings…" })
    )

    #expect(settingsMenuItem.action == action)
  }

  @Test
  func `app-level standard items, should include default images`() throws {
    #expect(NSMenuItem.about.image != nil)
    #expect(NSMenuItem.settings(action: nil).image != nil)
    #expect(NSMenuItem.help.image != nil)
    #expect(NSMenuItem.quit.image != nil)
  }

  @Test
  func `standard static items, should preserve key metadata`() throws {
    #expect(NSMenuItem.close.title == "Close")
    #expect(NSMenuItem.close.action == #selector(NSWindow.performClose(_:)))
    #expect(NSMenuItem.close.keyEquivalent == "w")

    #expect(NSMenuItem.findNext.tag == NSTextFinder.Action.nextMatch.rawValue)
    #expect(NSMenuItem.bold.tag == 2)
    #expect(NSMenuItem.showToolbar.keyEquivalentModifierMask == [.option, .command])
  }

  @Test
  func `standardMenuBar(settingsAction:), should preserve top level order and settings action`() throws {
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
    let menuBar = NSMenu.standardMenuBar(settingsAction: settingsAction)
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
  }
}
