import AppKit

extension NSView {
  public func addSubviews(_ views: NSView...) {
    views.forEach { addSubview($0) }
  }

  public func enumerateSubviews(using handler: (NSView) -> Void) {
    subviews.forEach {
      handler($0)
      $0.enumerateSubviews(using: handler)
    }
  }
}
