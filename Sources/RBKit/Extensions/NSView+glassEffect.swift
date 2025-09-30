import Cocoa

extension NSView {
  public func glassEffect(clear: Bool = false) -> NSView {
    if #available(macOS 26.0, *) {
      let glassView = NSGlassEffectView()
      glassView.contentView = self
      glassView.style = clear ? .clear : .regular
      return glassView
    } else {
      let glassView = NSVisualEffectView()
      glassView.addSubview(self)
      translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate {
        self.constraints(for: .pinningToEdges, of: glassView)
      }
      return glassView
    }
  }
}
