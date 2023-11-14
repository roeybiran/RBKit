import AppKit

extension NSStackView {

  // MARK: Lifecycle

  /// A convenience initializer for NSStackView.
  /// - Parameters:
  ///   - orientation: `.horizontal` by default.
  ///   - alignment: if `nil`, the default, orientation-appropriate alignment will be used: `.centerY` for horizontal stack views, `.centerX` for vertical.
  ///   - distribution: `.fill` by default.
  ///   - spacing: 8 by default.
  ///   - arrangedSubviews: the stack view’s subviews.
  public convenience init(
    _ orientation: NSUserInterfaceLayoutOrientation = .horizontal,
    alignment: NSLayoutConstraint.Attribute? = nil,
    spacing: CGFloat = 8,
    edgeInsets: NSEdgeInsets = .init(.zero),
    distribution: NSStackView.Distribution = .fill,
    @StackViewBuilder arrangedSubviews: () -> [NSView])
  {
    self.init()
    self.orientation = orientation
    self.alignment = alignment ?? (orientation == .horizontal ? .centerY : .centerX)
    self.spacing = spacing
    self.edgeInsets = edgeInsets
    self.distribution = distribution

    arrangedSubviews().forEach {
      addArrangedSubview($0)
    }
  }

  // MARK: Public

  public func addArrangedSubviews(_ views: NSView...) {
    views.forEach {
      addArrangedSubview($0)
    }
  }
}


// MARK: - StackViewBuilder

@resultBuilder
public enum StackViewBuilder {
  public static func buildBlock(_ components: NSView...) -> [NSView] {
    components
  }
}
