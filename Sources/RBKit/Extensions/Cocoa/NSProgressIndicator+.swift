import AppKit

extension NSProgressIndicator {
  public func setIsAnimating(_ flag: Bool, _ sender: Any? = nil) {
    flag ? startAnimation(sender) : stopAnimation(sender)
  }
}
