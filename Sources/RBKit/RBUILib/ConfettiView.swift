import AppKit

// MARK: - EmitterLayer

// https://nshipster.com/caemitterlayer/
// https://medium.com/@peteliev/what-do-you-know-about-caemitterlayer-368378d45c2e
// https://github.com/ugurethemaydin/SwiftConfettiView

private final class EmitterLayer: CAEmitterLayer {
  override func layoutSublayers() {
    super.layoutSublayers()

    emitterMode = .outline
    emitterShape = .line
    emitterSize = CGSize(width: frame.width, height: 1)
    emitterPosition = CGPoint(x: frame.midX, y: frame.maxY)
  }
}

// MARK: - ConfettiView

public final class ConfettiView: NSView {

  // MARK: Lifecycle

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  // MARK: Public

  public func emit(for duration: TimeInterval = 3) {
    guard let layer else { return assertionFailure() }

    let emitterLayer = EmitterLayer()
    emitterLayer.frame = bounds
    emitterLayer.needsDisplayOnBoundsChange = true

    layer.addSublayer(emitterLayer)

    emitterLayer.emitterCells = colors.map {
      confettiWithColor(color: $0)
    }

    emitterLayer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil)
    emitterLayer.birthRate = 0

    let animation = CAKeyframeAnimation(keyPath: #keyPath(CAEmitterLayer.birthRate))
    animation.duration = duration
    animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
    animation.fillMode = .forwards
    animation.values = [2, 0.5, 0]
    animation.keyTimes = [0, 0.5, 1]
    emitterLayer.add(animation, forKey: nil)
  }

  // MARK: Internal

  let colors: Set<NSColor> = [
    .red,
    .green,
    .blue,
    .yellow,
    .orange,
    .cyan,
    .magenta,
    .purple,
    .white,
  ]

  func setup() {
    wantsLayer = true
  }

  // MARK: Private

  private static let confettiImage: NSImage? = {
    guard let url = Bundle.module.url(forResource: "confetti", withExtension: "png") else {
      assertionFailure()
      return nil
    }
    return NSImage(byReferencing: url)
  }()

  private func confettiWithColor(color: NSColor) -> CAEmitterCell {
    let cell = CAEmitterCell()

    let cgImage = Self.confettiImage?.cgImage(forProposedRect: nil, context: nil, hints: nil)
    assert(cgImage != nil)
    cell.contents = cgImage

    cell.birthRate = 50.0
    cell.lifetime = 10.0

    cell.velocity = -CGFloat(cell.birthRate * cell.lifetime)
    cell.velocityRange = cell.velocity / 2

    cell.emissionLongitude = .pi
    cell.emissionRange = .pi / 4
    cell.scaleRange = 0.25
    cell.scale = 1.0 - cell.scaleRange
    cell.color = color.cgColor

    cell.spinRange = .pi * 6
    cell.spin = 180.0.radians

    return cell
  }

}
