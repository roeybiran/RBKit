import AppKit

extension NSMenuItem {

  // MARK: Lifecycle

  public convenience init(
    _ title: String,
    action: Selector? = nil,
    keyEquivalent: String = "",
    @MenuBuilder builder: (() -> [NSMenuItem]) = { [] })
  {
    self.init(title: title, action: action, keyEquivalent: keyEquivalent)
    let children = builder()
    if !children.isEmpty {
      submenu = NSMenu(title: title)
      submenu?.items = children
    }
  }

  // MARK: Public

  // MARK: - special system menus

  public static func settingsMenuItem() -> NSMenuItem {
    NSMenuItem("Settings…", keyEquivalent: ",")
  }

  @MainActor
  public static func servicesMenu() -> NSMenuItem {
    let title = "Services"
    let menuItem = NSMenuItem(title)
    menuItem.submenu = NSMenu(title)
    NSApp.servicesMenu = menuItem.submenu
    return menuItem
  }

  @MainActor
  public static func windowMenu(@MenuBuilder builder: (() -> [NSMenuItem]) = { [] })
    -> NSMenuItem
  {
    let title = "Window"
    let menuItem = NSMenuItem(title)
    menuItem.submenu = NSMenu(title: title)
    let children = builder()
    if !children.isEmpty {
      menuItem.submenu?.items = children
    }
    NSApp.windowsMenu = menuItem.submenu
    return menuItem
  }

  @MainActor
  public static func helpMenu(@MenuBuilder builder: (() -> [NSMenuItem]) = { [] })
    -> NSMenuItem
  {
    let title = "Help"
    let menuItem = NSMenuItem(title)
    menuItem.submenu = NSMenu(title)
    NSApp.helpMenu = menuItem.submenu
    let children = builder()
    if !children.isEmpty {
      menuItem.submenu?.items = children
    }
    return menuItem
  }

  public static func _sectionHeader(title: String) -> NSMenuItem {
    if #available(macOS 14.0, *) {
      NSMenuItem.sectionHeader(title: title)
    } else {
      NSMenuItem(title: title, action: nil, keyEquivalent: "").set(\.isEnabled, to: false)
    }
  }
}
