import Cocoa

extension NSView {
  public func addSubviews(_ views: NSView...) {
    views.forEach { addSubview($0) }
  }
}
