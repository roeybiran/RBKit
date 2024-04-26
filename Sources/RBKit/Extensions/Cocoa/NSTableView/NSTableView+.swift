import AppKit

extension NSTableView {
  /// makeCell
  /// - [Creating and Configuring an NSTextField Cell](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TableView/PopulatingView-TablesProgrammatically/PopulatingView-TablesProgrammatically.html#//apple_ref/doc/uid/10000026i-CH14-SW7)
  public func makeCell<T: NSView>(
    withIdentifier identifier: NSUserInterfaceItemIdentifier = "\(T.self)",
    owner: Any? = nil)
  -> T
  {
    if let existingCell = makeView(withIdentifier: identifier, owner: owner) as? T {
      return existingCell
    } else {
      let newCell = T(frame: .zero)
      newCell.identifier = identifier
      return newCell
    }
  }

  public static let bigSurVerticalInsets = CGFloat.standard
}
