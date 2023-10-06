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

extension [NSLayoutConstraint] {
  public func activate() {
    NSLayoutConstraint.activate(self)
  }
}

// MARK: - LayoutGroup

// https://www.avanderlee.com/swift/result-builders/

public protocol LayoutGroup {
  var constraints: [NSLayoutConstraint] { get }
}

extension NSLayoutConstraint {
  public static func activate(@ConstraintsBuilder constraints: () -> [NSLayoutConstraint]) {
    Self.activate(constraints())
  }
}

// MARK: - NSLayoutConstraint + LayoutGroup

extension NSLayoutConstraint: LayoutGroup {
  public var constraints: [NSLayoutConstraint] { [self] }
}

// MARK: - Array + LayoutGroup

extension [NSLayoutConstraint]: LayoutGroup {
  public var constraints: [NSLayoutConstraint] { self }
}

// MARK: - ConstraintsBuilder

@resultBuilder
public enum ConstraintsBuilder {
  public static func buildBlock(_ components: LayoutGroup...) -> [NSLayoutConstraint] {
    components.flatMap { $0.constraints }
  }
}
