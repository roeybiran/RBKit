import AppKit

extension NSStatusItem {
  @MainActor
  public static func main(
    menu: NSMenu = NSMenu(),
    length: CGFloat = NSStatusItem.variableLength,
    statusBar: NSStatusBar = .system,
    imageName: String = "StatusItem"
  ) -> NSStatusItem {
    let statusItem = statusBar.statusItem(withLength: length)
    statusItem.button?.image = NSImage(named: imageName)
    statusItem.button?.image?.isTemplate = true
    statusItem.button?.target = statusItem
    statusItem.menu = menu
    #if DEBUG
    statusItem.button?.title = "DEV"
    #elseif PROFILE
    statusItem.button?.title = "PRF"
    #endif
    return statusItem
  }
}
