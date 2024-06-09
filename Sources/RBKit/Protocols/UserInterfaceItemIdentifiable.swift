import AppKit

public protocol UserInterfaceItemIdentifiable: AnyObject {
  static var userInterfaceIdentifier: NSUserInterfaceItemIdentifier { get }
}
