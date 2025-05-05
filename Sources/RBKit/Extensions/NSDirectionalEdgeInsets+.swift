import AppKit

extension NSDirectionalEdgeInsets {
  public init(top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
    self.init(top: top, leading: leading, bottom: bottom, trailing: trailing)
  }

  public init(_ constant: CGFloat) {
    self.init(top: constant, leading: constant, bottom: constant, trailing: constant)
  }
}
