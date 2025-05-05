import QuartzCore

extension CACornerMask {
  public static let topLeft = Self.layerMinXMaxYCorner
  public static let topRight = Self.layerMaxXMaxYCorner
  public static let bottomRight = Self.layerMaxXMinYCorner
  public static let bottomLeft = Self.layerMinXMinYCorner
  public static let all = Self(arrayLiteral: .topLeft, .topRight, .bottomLeft, .bottomRight)
}
