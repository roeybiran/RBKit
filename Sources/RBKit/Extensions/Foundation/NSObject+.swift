import AppKit

extension NSObject: UserInterfaceItemIdentifiable {
  public static var userInterfaceIdentifier: NSUserInterfaceItemIdentifier {
    "\(Self.self)"
  }
}
