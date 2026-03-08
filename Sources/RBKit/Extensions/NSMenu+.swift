import AppKit

extension NSMenu {

  // MARK: Lifecycle

  public convenience init(_ title: String, @MenuBuilder builder: () -> [NSMenuItem] = { [] }) {
    self.init(title: title)
    items = builder()
  }

  // MARK: Public

  public static func menuBar(@MenuBuilder builder: () -> [NSMenuItem]) -> NSMenu {
    NSMenu(String.appName, builder: builder)
  }

  /// A programmatically created application menu bar (`NSApp.mainMenu`). The menu’s structure and contents are an exact clone of those in a Storyboard–based, non–modified menu bar (as of **Xcode 14.2**). This is not meant to be used directly in your project (hence the lack of the `public` modifier), but rather copied and modified to suit your needs.
  @MainActor
  public static func standardMenuBar(
    settingsAction: Selector?,
    settingsTarget: AnyObject?,
  ) -> NSMenu {
    NSMenu(String.appName) {
      NSMenuItem.applicationMenu(
        settingsAction: settingsAction,
        settingsTarget: settingsTarget,
      )
      NSMenuItem.fileMenu
      NSMenuItem.editMenu
      NSMenuItem.formatMenu
      NSMenuItem.viewMenu
      NSMenuItem.windowMenu()
      NSMenuItem.helpMenu()
    }
  }
}
