import AppKit

extension NSWindowController {
  public func showAndCenter(_ sender: Any?) {
    showWindow(sender)
    window?.center()
  }
}
