import AppKit
import Foundation

extension Notification.Name {
  static let areUpdatesAvailable = Self("areUpdatesAvailable")
}

extension String {
  static let defaultMenuItemTitle = Self("Check for Updates…")
  static let updatesAvailableMenuItemTitle = Self("Updates Available…")
}

@MainActor
extension NSImage {
  static let updatesAvailable = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: nil)
}
