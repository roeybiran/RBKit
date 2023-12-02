import AppKit

extension NSTableView {
  // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TableView/PopulatingView-TablesProgrammatically/PopulatingView-TablesProgrammatically.html#//apple_ref/doc/uid/10000026i-CH14-SW7
  public func makeCell<T: NSView>(
    withIdentifier identifier: NSUserInterfaceItemIdentifier,
    owner: Any? = nil,
    frame: NSRect = .zero)
  -> T
  {
    if let existingCell = makeView(withIdentifier: identifier, owner: owner ?? self) as? T {
      return existingCell
    } else {
      let newCell = T(frame: frame)
      newCell.identifier = identifier
      return newCell
    }
  }
}
