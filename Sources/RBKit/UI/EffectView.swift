import AppKit

// MARK: - EffectView

public final class EffectView: NSView {

  // MARK: Lifecycle

  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }

  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public enum Effect: Int, Codable, Hashable, Sendable {
    case none
    case translucency
    case glass
  }

  public var contentView: NSView? {
    didSet {
      guard contentView !== oldValue else { return }
      updateContentView()
    }
  }

  public var effect = Effect.none {
    didSet {
      guard effect != oldValue else { return }
      updateContentView()
    }
  }

  // MARK: Private

  private var effectView: NSView?

  private func updateContentView() {
    if #available(macOS 26.0, *), let glassView = effectView as? NSGlassEffectView {
      glassView.contentView = nil
    }
    effectView?.removeFromSuperview()

    guard let contentView else { return }

    let nextContainerView: NSView
    let resizesContentView: Bool
    switch effect {
    case .glass:
      if #available(macOS 26.0, *) {
        let glassView = NSGlassEffectView()
        glassView.contentView = contentView
        glassView.style = .regular
        nextContainerView = glassView
        resizesContentView = false
      } else {
        nextContainerView = makeTranslucentEffectView(containing: contentView)
        resizesContentView = true
      }

    case .translucency:
      nextContainerView = makeTranslucentEffectView(containing: contentView)
      resizesContentView = true

    case .none:
      let plainView = NSView()
      plainView.addSubview(contentView)
      contentView.translatesAutoresizingMaskIntoConstraints = true
      contentView.autoresizingMask = [.width, .height]
      nextContainerView = plainView
      resizesContentView = true
    }

    addSubview(nextContainerView)
    nextContainerView.frame = bounds
    nextContainerView.autoresizingMask = [.width, .height]
    if resizesContentView {
      contentView.frame = nextContainerView.bounds
    }
    effectView = nextContainerView
  }

  private func makeTranslucentEffectView(containing contentView: NSView) -> NSVisualEffectView {
    let effectView = NSVisualEffectView()
    effectView.blendingMode = .behindWindow
    effectView.material = .underWindowBackground
    effectView.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = true
    contentView.autoresizingMask = [.width, .height]
    return effectView
  }
}
