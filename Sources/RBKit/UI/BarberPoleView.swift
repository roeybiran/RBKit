import AppKit

public final class BarberPoleView: NSView {

  // MARK: Lifecycle

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    clipsToBounds = true
    wantsLayer = true
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var maxOpacity: Float = 0.5

  @Invalidating(.display) public var color = NSColor.controlAccentColor

  @Invalidating(.display) public var cornerRadius = 8.0

  @Invalidating(.display) public var isAnimating = false

  public override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    layer?.opacity = isAnimating ? maxOpacity : 0
    layer?.masksToBounds = true
    layer?.cornerRadius = cornerRadius

    let baseRect = bounds
    let stripeWidth = baseRect.width / stripeCount

    for stripe in [stripe1, stripe2] {
      let path = CGMutablePath()

      path.move(to: CGPoint(x: baseRect.minX, y: baseRect.minY))
      path.addLine(to: CGPoint(x: stripeWidth * angle, y: baseRect.maxY))
      path.addLine(to: CGPoint(x: (stripeWidth * angle) + stripeWidth, y: baseRect.maxY))
      path.addLine(to: CGPoint(x: stripeWidth, y: baseRect.minY))
      path.closeSubpath()

      stripe.path = path
      stripe.fillColor = color.cgColor
    }

    for group in [stripeGroup1, stripeGroup2] {
      group.frame = baseRect
      group.instanceCount = Int((baseRect.width / stripeWidth) / 2)
      group.instanceTransform = CATransform3DMakeTranslation(stripeWidth * 2, 0, 0)
      group.anchorPoint = .zero
    }

    stripeGroup1.addSublayer(stripe1)
    stripeGroup2.addSublayer(stripe2)

    layer?.addSublayer(stripeGroup1)
    layer?.addSublayer(stripeGroup2)

    stripeGroup1.position.x = 0
    positionAnimation1.fromValue = -baseRect.width
    positionAnimation1.repeatCount = repeatCount
    positionAnimation1.speed = speed

    stripeGroup2.position.x = baseRect.width
    positionAnimation2.fromValue = 0
    positionAnimation2.repeatCount = repeatCount
    positionAnimation2.speed = speed

    if isAnimating {
      stripeGroup1.add(positionAnimation1, forKey: "animation1")
      stripeGroup2.add(positionAnimation2, forKey: "animation2")
    } else {
      stripeGroup1.removeAnimation(forKey: "animation1")
      stripeGroup2.removeAnimation(forKey: "animation2")
    }
  }

  // MARK: Private

  private let stripeGroup1 = CAReplicatorLayer()
  private let stripe1 = CAShapeLayer()
  private let stripeGroup2 = CAReplicatorLayer()
  private let stripe2 = CAShapeLayer()
  private let positionAnimation1 = CABasicAnimation(keyPath: "position.x")
  private let positionAnimation2 = CABasicAnimation(keyPath: "position.x")
  private let repeatCount = Float.infinity
  private let speed: Float = 0.2
  private let stripeCount: CGFloat = 10
  private let angle: CGFloat = 2
}
