import AppKit

extension NSMenuItem {
  public static func _sectionHeader(title: String) -> NSMenuItem {
    if #available(macOS 14.0, *) {
      NSMenuItem.sectionHeader(title: title)
    } else {
      NSMenuItem(title: title, action: nil, keyEquivalent: "").set(\.isEnabled, to: false)
    }
  }
}
