import AppKit

// MARK: - ToastView

public final class ToastView: NSView {

  // MARK: Lifecycle

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    task?.cancel()
    logger.log("NotificationView: deinit")
  }

  // MARK: Public

  public let textField: NSTextField = {
    let textField = NSTextField(labelWithString: "")
    textField.isSelectable = false
    return textField
  }()

  public var onDismiss: (() -> Void)?
  public var transitionDuration = 0.3
  public var notificationLifetime: TimeInterval = 3
  public var maxWidth: CGFloat = 200
  public var hideProgressIndicator = false
  public var hideCloseButton = false

  public override var isOpaque: Bool {
    true
  }

  public override func viewWillMove(toWindow newWindow: NSWindow?) {
    super.viewWillMove(toWindow: newWindow)

    wantsLayer = true
    translatesAutoresizingMaskIntoConstraints = false

    progressIndicator.translatesAutoresizingMaskIntoConstraints = false

    let closeButton = NSButton(closeButtonWithTarget: self, action: #selector(dismiss(_:)))

    let toastStackView = NSStackView(views: [])
    toastStackView.addArrangedSubview(closeButton)
    toastStackView.addArrangedSubview(textField)

    boxContentStackView.orientation = .vertical
    boxContentStackView.edgeInsets = .init(spacing)
    boxContentStackView.addArrangedSubview(toastStackView)
    boxContentStackView.addSubview(progressIndicator)

    box.contentViewMargins = .zero
    box.cornerRadius = spacing
    box.borderWidth = 1
    box.boxType = .custom
    box.borderColor = .separatorColor
    box.fillColor = .windowBackgroundColor
    box.clipsToBounds = true

    box.shadow = NSShadow()
    box.shadow?.shadowBlurRadius = 4
    box.shadow?.shadowOffset = .init(width: 0, height: -2)

    guard let boxContentView = box.contentView else { return }

    boxContentView.wantsLayer = true
    boxContentView.layer?.cornerRadius = spacing
    boxContentView.layer?.masksToBounds = true
    boxContentView.addSubview(boxContentStackView)
    boxContentView.clipsToBounds = true

    box.translatesAutoresizingMaskIntoConstraints = false

    layer?.zPosition = .greatestFiniteMagnitude
    layer?.isOpaque = true
    layer?.opacity = visibleOpacity
    layer?.anchorPoint = visibleAnchorPointY

    addSubview(box)

    progressIndicator.isHidden = hideProgressIndicator
    closeButton.isHidden = hideCloseButton

    NSLayoutConstraint.activate {
      progressIndicator.bottomAnchor.constraint(equalTo: boxContentStackView.bottomAnchor)
      progressIndicator.trailingAnchor.constraint(equalTo: boxContentStackView.trailingAnchor)
      progressIndicator.leadingAnchor.constraint(equalTo: boxContentStackView.leadingAnchor)
      progressIndicator.heightAnchor.constraint(equalToConstant: 2)

      boxContentStackView.constraints(for: .pinningToEdges, of: boxContentView)

      box.constraints(for: .pinningToEdges, of: self)
      box.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth)
    }
  }

  public func show(in anchorView: NSView) {
    anchorView.addSubview(self)

    NSLayoutConstraint.activate {
      // centerXAnchor.constraint(equalTo: anchorView.centerXAnchor)
      trailingAnchor.constraint(equalTo: anchorView.layoutMarginsGuide.trailingAnchor)
      topAnchor.constraint(equalTo: anchorView.layoutMarginsGuide.topAnchor)
    }

    animationGroup.animations = [anchorPointAnimation, opacityAnimation]
    animationGroup.duration = transitionDuration

    opacityAnimation.fromValue = hiddenOpacity
    anchorPointAnimation.fromValue = hiddenAnchorPoint

    layer?.add(animationGroup, forKey: nil)

    NSAnimationContext.current.completionHandler = { [weak self] in
      self?.countdown()
    }
  }

  @objc
  public func dismiss(_: Any?) {
    guard let selfLayer = layer else { return }

    NSAnimationContext.current.completionHandler = { [weak self] in
      self?.removeFromSuperview()
      self?.onDismiss?()
    }

    task?.cancel()

    selfLayer.opacity = hiddenOpacity
    opacityAnimation.fromValue = visibleOpacity
    selfLayer.anchorPoint = hiddenAnchorPoint
    anchorPointAnimation.fromValue = visibleAnchorPointY

    animationGroup.timingFunction = .init(name: .easeIn)
    selfLayer.add(animationGroup, forKey: nil)
  }

  // MARK: Private

  private let boxContentStackView = NSStackView(views: [])

  private let box = NSBox()
  private let hiddenOpacity: Float = 0.0
  private let visibleOpacity: Float = 1.0
  private let hiddenAnchorPoint = CGPoint(x: 0, y: -1.0)
  private let visibleAnchorPointY = CGPoint.zero
  private let spacing: CGFloat = 8.0
  private let opacityAnimation = CABasicAnimation(keyPath: "opacity")
  private let anchorPointAnimation: CASpringAnimation = {
    let anchorPointAnimation = CASpringAnimation(keyPath: "anchorPoint")
    anchorPointAnimation.damping = 20 // Damping ratio to reduce oscillation
    anchorPointAnimation.initialVelocity = 5 // Initial velocity for the spring animation
    anchorPointAnimation.stiffness = 150 // Stiffness of the spring
    anchorPointAnimation.mass = 1 // Mass of the object being animated
    anchorPointAnimation.duration = anchorPointAnimation.settlingDuration // Calculate duration based on the spring properties
    return anchorPointAnimation
  }()

  private let animationGroup: CAAnimationGroup = {
    let animationGroup = CAAnimationGroup()
    animationGroup.timingFunction = .init(name: .easeOut)
    return animationGroup
  }()

  private let progressIndicator: NSProgressIndicator = {
    let progressIndicator = BarProgressIndicator()
    progressIndicator.style = .bar
    progressIndicator.isIndeterminate = false
    progressIndicator.controlSize = .mini
    progressIndicator.doubleValue = 100
    return progressIndicator
  }()

  private var task: Task<Void, Error>?

  private func countdown() {
    task?.cancel()
    task = Task { [weak self] in
      guard let self else { return }
      while progressIndicator.animator().doubleValue > 0 {
        try Task.checkCancellation()
        progressIndicator.animator().doubleValue -= 1
        try? await Task.sleep(for: .seconds(notificationLifetime / 100))
      }
      dismiss(nil)
    }
  }
}

extension NSButton {
  convenience init(closeButtonWithTarget target: Any?, action: Selector?) {
    let image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Close")!
    self.init(image: image, target: target, action: action)
    isBordered = false
  }
}
