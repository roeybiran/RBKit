import AppKit

open class OperationButton: NSButton {

  // MARK: Lifecycle

  public init(idleTitle: String) {
    self.idleTitle = idleTitle
    super.init(frame: .zero)
    title = idleTitle
    imagePosition = .imageLeading
    clipsToBounds = true
    addSubview(barberPoleView)
    translatesAutoresizingMaskIntoConstraints = false

    barberPoleView.translatesAutoresizingMaskIntoConstraints = false

    let widthConstraint = widthAnchor.constraint(equalToConstant: intrinsicContentSize.width)
    self.widthConstraint = widthConstraint

    NSLayoutConstraint.activate {
      barberPoleView.constraints(for: .pinningToEdges, of: self)
      widthConstraint
    }
  }

  required public init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public struct Status: Hashable {
    public init(_ kind: Kind, title: String) {
      self.kind = kind
      self.title = title
    }

    public enum Kind {
      case error
      case busy
      case success
    }

    public let kind: Kind
    public let title: String

  }

  public var status: Status? {
    didSet {
      NSAnimationContext.current.timingFunction = .init(name: .easeInEaseOut)
      NSAnimationContext.current.duration = 0.2
      barberPoleView.isAnimating = status?.kind == .busy
      animator().isEnabled = status == nil || status?.kind == .error
      animator().title = status?.title ?? idleTitle

      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        assert(widthConstraint != nil)
        widthConstraint?.animator().constant = intrinsicContentSize.width
      }

      animator().image =
        switch status?.kind {
        case .error:
          Self.errorImage
        case .success:
          Self.successImage
        case .busy, nil:
          nil
        }

      animator().bezelColor =
        switch status?.kind {
        case .error:
          .systemRed
        case .success:
          .systemGreen
        case .busy, nil:
          nil
        }

      if status?.kind != .busy {
        window?.animator().makeFirstResponder(self)
      }
    }
  }

  // MARK: Internal

  static let errorImage = NSImage(
    systemSymbolName: "exclamationmark.triangle.fill",
    accessibilityDescription: "Error",
  )
  static let successImage = NSImage(
    systemSymbolName: "checkmark.circle.fill",
    accessibilityDescription: "Success",
  )

  // MARK: Private

  private let idleTitle: String
  private var widthConstraint: NSLayoutConstraint?
  private let barberPoleView = BarberPoleView()
}
