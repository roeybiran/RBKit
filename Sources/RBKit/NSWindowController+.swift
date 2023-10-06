import Cocoa

extension NSWindowController {
  public func showAndCenter(_ sender: Any?) {
    showWindow(sender)
    window?.center()
  }
}
