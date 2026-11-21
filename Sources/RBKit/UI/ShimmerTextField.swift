import AppKit

public final class ShimmerTextField: NSTextField {

  // MARK: Public

  public override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    setupShimmerEffect()
  }

  // MARK: Private

  private func setupShimmerEffect() {
    wantsLayer = true

    let gradientLayer = CAGradientLayer()
    let colors: [NSColor] = [
      .white,
      .white.withAlphaComponent(0.5),
      .white,
    ]

    gradientLayer.colors = colors.map(\.cgColor)

    gradientLayer.locations = [-0.6, -0.3, 0]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    gradientLayer.frame = bounds

    layer?.mask = gradientLayer

    let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))

    animation.toValue = [1.0, 1.3, 1.6]
    animation.duration = 0.8
    animation.repeatCount = .infinity
    gradientLayer.add(animation, forKey: "shimmer")
  }
}
