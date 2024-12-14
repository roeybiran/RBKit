import QuartzCore

extension CASpringAnimation {
  public static func defaultSpring(
    keyPath: String, perceptualDuration: CFTimeInterval = 0.3, bounce: CGFloat = 0.3
  ) -> CASpringAnimation {
    if #available(macOS 14.0, *) {
      let springAnimation = CASpringAnimation(
        perceptualDuration: perceptualDuration, bounce: bounce)
      springAnimation.keyPath = keyPath
      return springAnimation
    } else {
      let springAnimation = CASpringAnimation(keyPath: keyPath)
      springAnimation.duration = springAnimation.settlingDuration
      springAnimation.damping = 15
      springAnimation.initialVelocity = 10
      springAnimation.mass = 1
      springAnimation.stiffness = 150
      return springAnimation
    }
  }
}
