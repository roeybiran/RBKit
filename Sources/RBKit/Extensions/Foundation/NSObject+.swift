import AppKit

extension NSObject {
  public static var userInterfaceIdentifier: NSUserInterfaceItemIdentifier {
    "\(Self.self)"
  }
}
