import AppKit

// inspiration: https://stackoverflow.com/a/46123489
extension NSView {

  // MARK: Public

  public func startShimmering(
    shimmerColor: NSColor = .white,
    duration: TimeInterval = 1,
    repeatDelay _: TimeInterval = 1,
  ) {
    stopShimmering()

    let gradientLayer = CAGradientLayer()
    gradientLayer.name = Self.layerName
    let alphaColor = shimmerColor.withAlphaComponent(0).cgColor
    let colors: [CGColor] = [alphaColor, shimmerColor.cgColor, alphaColor]
    gradientLayer.colors = colors
    gradientLayer.frame = bounds
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    gradientLayer.anchorPoint = .zero

    let allowance = 1.0

    let shimmerAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.position))
    let fromValue = CGPoint(x: -bounds.width * allowance, y: 0)
    shimmerAnimation.fromValue = fromValue
    shimmerAnimation.toValue = CGPoint(x: bounds.width * allowance, y: 0)
    shimmerAnimation.duration = duration
    shimmerAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    shimmerAnimation.repeatCount = .greatestFiniteMagnitude

    gradientLayer.add(shimmerAnimation, forKey: Self.animationKey)

    wantsLayer = true
    layer?.masksToBounds = true
    layer?.addSublayer(gradientLayer)
  }

  public func stopShimmering() {
    let gradientLayer = layer?.sublayers?.first { $0.name == Self.layerName }
    gradientLayer?.removeAnimation(forKey: Self.animationKey)
    gradientLayer?.removeFromSuperlayer()
  }

  // MARK: Private

  private static let layerName = "GradientLayer"
  private static let animationKey = "GradientAnimation"

}
