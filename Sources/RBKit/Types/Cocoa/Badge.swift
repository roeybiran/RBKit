import AppKit

open class Badge: NSBox {

  // MARK: Lifecycle

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    spacing = 4
    padding = CGFloat.standard / 2

    textField.textColor = .secondaryLabelColor
    textField.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    textField.alignment = .center
    textField.lineBreakMode = .byTruncatingMiddle
    textField.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)

    stackView.setViews([imageView, textField], in: .center)
    stackView.translatesAutoresizingMaskIntoConstraints = false

    contentView?.addSubview(stackView)
    contentViewMargins = .zero
    boxType = .custom
    titlePosition = .noTitle
    borderWidth = .zero
    cornerRadius = 8
    sizeToFit()

    guard let contentView else { return }

    NSLayoutConstraint.activate {
      stackView.constraints(for: .pinningToEdges, of: contentView)
    }
  }

  required public init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var padding: CGFloat {
    get { stackView.edgeInsets.top }
    set { stackView.edgeInsets = .init(newValue) }
  }

  public var spacing: CGFloat {
    get { stackView.spacing }
    set { stackView.spacing = newValue }
  }

  public var stringValue: String {
    get { textField.stringValue }
    set { textField.stringValue = newValue }
  }

  public var isLabelHidden: Bool {
    get { textField.isHidden }
    set { textField.isHidden = newValue }
  }

  public var image: NSImage? {
    get { imageView.image }
    set { imageView.image = newValue }
  }

  // MARK: Private

  private let stackView = NSStackView(views: [])
  private let textField = NSTextField(labelWithString: "Badge")
  private let imageView = NSImageView()
}
