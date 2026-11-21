import AppKit

public final class BorderedImageView: NSImageView {

  // MARK: Lifecycle

  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    wantsLayer = true
    clipsToBounds = true
    layer?.mask = maskLayer
    layer?.addSublayer(imageLayer)
  }

  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  @Invalidating(.display) public var borerColor = NSColor.controlAccentColor
  @Invalidating(.display) public var borderWidth = CGFloat(1)

  public override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    if let image {
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)

      imageLayer.frame = bounds
      imageLayer.contents = cgImage

      maskLayer.frame = bounds.insetBy(dx: -borderWidth, dy: -borderWidth)
      maskLayer.contents = cgImage

      layer?.backgroundColor = borerColor.cgColor
    }
  }

  // MARK: Internal

  let maskLayer = CALayer()
  let imageLayer = CALayer()
}
