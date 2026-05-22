import AppKit

extension NSImage {
  public func draw(rect: CGRect, tint color: NSColor) {
    let tintedImage = NSImage(size: size, flipped: false) { bounds in
      self.draw(in: bounds, from: bounds, operation: .sourceOver, fraction: color.alphaComponent)
      color.setFill()
      bounds.fill(using: .sourceAtop)
      return true
    }
    tintedImage.draw(in: rect)
  }
}
