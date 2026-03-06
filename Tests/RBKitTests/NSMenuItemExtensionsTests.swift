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
  func `init with empty builder, should keep submenu nil`() throws {
    let menuItem = NSMenuItem("Parent") {
    }

    #expect(menuItem.submenu == nil)
  }

  @Test
  func `withChildren, should return self and replace submenu items`() throws {
    let menuItem = NSMenuItem("Parent")
    let child1 = NSMenuItem("Child 1")
    let child2 = NSMenuItem("Child 2")

    let returned = menuItem.withChildren {
      child1
    }
    var submenu = try #require(menuItem.submenu)

    #expect(returned === menuItem)
    #expect(submenu.items.count == 1)
    #expect(submenu.items.first === child1)

    menuItem.withChildren {
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
  func `windowMenu(app:builder:), should set windowsMenu on provided app`() throws {
    let app = NSApplication.shared
    let originalWindowsMenu = app.windowsMenu
    defer { app.windowsMenu = originalWindowsMenu }

    let child = NSMenuItem("Child")
    let menuItem = NSMenuItem.windowMenu(app: app) {
      child
    }
    let submenu = try #require(menuItem.submenu)

    #expect(menuItem.title == "Window")
    #expect(submenu.items.count == 1)
    #expect(submenu.items.first === child)
    #expect(app.windowsMenu === submenu)
  }

  @Test
  func `helpMenu(app:builder:), should set helpMenu on provided app`() throws {
    let app = NSApplication.shared
    let originalHelpMenu = app.helpMenu
    defer { app.helpMenu = originalHelpMenu }

    let child = NSMenuItem("Child")
    let menuItem = NSMenuItem.helpMenu(app: app) {
      child
    }
    let submenu = try #require(menuItem.submenu)

    #expect(menuItem.title == "Help")
    #expect(submenu.items.count == 1)
    #expect(submenu.items.first === child)
    #expect(app.helpMenu === submenu)
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
  func `standardMenuBar, should preserve top level order`() throws {
    let app = NSApplication.shared
    let originalServicesMenu = app.servicesMenu
    let originalWindowsMenu = app.windowsMenu
    let originalHelpMenu = app.helpMenu
    defer {
      app.servicesMenu = originalServicesMenu
      app.windowsMenu = originalWindowsMenu
      app.helpMenu = originalHelpMenu
    }

    let menuBar = NSMenu.standardMenuBar
    let titles = menuBar.items.map(\.title)

    #expect(titles == [
      NSMenuItem.appName,
      "File",
      "Edit",
      "Format",
      "View",
      "Window",
      "Help",
    ])
  }
}
