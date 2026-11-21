import AppKit

open class BarProgressIndicator: NSProgressIndicator {

  // MARK: Lifecycle

  init() {
    super.init(frame: .zero)
    wantsLayer = true
    clipsToBounds = true
    layerContentsRedrawPolicy = .onSetNeedsDisplay
    layer?.addSublayer(fillLayer)
  }

  required public init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  open override var wantsUpdateLayer: Bool {
    true
  }

  open override func updateLayer() {
    layer?.backgroundColor = trackBackgroundColor.cgColor
    fillLayer.backgroundColor = trackColor.cgColor
    let value = bounds.width * (1 - doubleValue / 100)
    fillLayer.frame = bounds.offsetBy(dx: -value, dy: 0)
  }

  // MARK: Public

  @Invalidating(.display) public var trackBackgroundColor = NSColor.controlBackgroundColor

  @Invalidating(.display) public var trackColor = NSColor.controlAccentColor

  // MARK: Private

  private let fillLayer = CALayer()

}
