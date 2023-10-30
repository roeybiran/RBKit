import Cocoa

extension NSView {
  public enum ConstraintType {
    case pinningToEdges
    case pinningToCenter
  }

  public enum Offset {
    case individual(horizontal: CGFloat, vertical: CGFloat)
    case uniform(CGFloat)
  }

  public func addSubviews(_ views: NSView...) {
    views.forEach { addSubview($0) }
  }

  public func constraints(
    for type: ConstraintType,
    of otherView: NSView,
    offset: Offset = .uniform(0)) -> [NSLayoutConstraint]
  {
    var verticalOffset: CGFloat = 0
    var horizontalOffset: CGFloat = 0
    switch offset {
      case .individual(let horizontal, let vertical):
        horizontalOffset = horizontal
        verticalOffset = vertical
      case .uniform(let offset):
        verticalOffset = offset
        horizontalOffset = offset
    }

    switch type {
      case .pinningToEdges:
        return [
          topAnchor.constraint(equalTo: otherView.topAnchor, constant: verticalOffset),
          trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: -horizontalOffset),
          bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: -verticalOffset),
          leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: horizontalOffset),
        ]
      case .pinningToCenter:
        return [
          centerXAnchor.constraint(equalTo: otherView.centerXAnchor, constant: 0),
          centerYAnchor.constraint(equalTo: otherView.centerYAnchor, constant: 0),
        ]
    }
  }
}
