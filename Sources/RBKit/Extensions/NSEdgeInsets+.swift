import Foundation

extension NSEdgeInsets {
  public init(_ constant: CGFloat) {
    self.init(
      top: constant,
      left: constant,
      bottom: constant,
      right: constant
    )
  }

  public init(horizontal: CGFloat, vertical: CGFloat) {
    self.init(
      top: vertical,
      left: horizontal,
      bottom: vertical,
      right: horizontal
    )
  }
}
