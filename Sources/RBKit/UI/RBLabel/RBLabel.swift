import AppKit
import Dependencies

// MARK: - RBLabel

public final class RBLabel: NSView {

  // MARK: Lifecycle

  public override init(frame frameRect: NSRect = .zero) {
    super.init(frame: frameRect)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public struct TextSizeKey: Hashable {
    public init(
      fontName: String,
      fontSize: CGFloat,
      string: String,
    ) {
      self.fontName = fontName
      self.fontSize = fontSize
      self.string = string
    }

    public let fontName: String
    public let fontSize: CGFloat
    public let string: String
  }

  public static let paragraphStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    style.lineBreakMode = .byTruncatingTail
    return style
  }()

  public let horizontalPadding = CGFloat(4)
  public let verticalPadding = CGFloat(2)

  @Invalidating(.display) public var contentColor = NSColor.systemGray

  @Invalidating(.display) public var selectedContentColor = NSColor.alternateSelectedControlTextColor

  @Invalidating(.display) public var selectedContentBackgroundColor = NSColor.controlAccentColor

  @Invalidating(.display, .layout, .intrinsicContentSize)
  public var image: NSImage? = nil

  @Invalidating(.display) public var isSelected = false

  @Invalidating(.display) public var isBordered = false

  @Invalidating(.display, .layout, .intrinsicContentSize)
  public var fontSize = NSFont.smallSystemFontSize

  @Invalidating(.display, .layout, .intrinsicContentSize)
  public var stringValue = ""

  public var backgroundColor: NSColor {
    contentColor.withAlphaComponent(0.1)
  }

  public override var intrinsicContentSize: NSSize {
    let measuredTextFittingSize = measuredTextFittingSize()
    let textWidth = measuredTextFittingSize.width
    let height = ceil(max(measuredTextFittingSize.height, image?.size.height ?? 0) + (verticalPadding * 2))
    let imageWidth = image == nil ? 0 : max(0, height - (verticalPadding * 2))
    return .init(
      width: ceil((horizontalPadding * 2) + imageWidth + textWidth),
      height: height,
    )
  }

  public var font: NSFont {
    .systemFont(ofSize: fontSize)
  }

  public var contentTintColor: NSColor {
    isSelected ? selectedContentColor : contentColor
  }

  public var backgroundFillColor: NSColor {
    isSelected ? selectedContentBackgroundColor : backgroundColor
  }

  public var borderStrokeColor: NSColor {
    isSelected ? selectedContentBackgroundColor : contentColor
  }

  public override func layout() {
    super.layout()

    let measuredTextFittingSize = measuredTextFittingSize()
    let textWidth = measuredTextFittingSize.width
    let availableContentHeight = max(0, bounds.height - (verticalPadding * 2))
    let textHeight = min(measuredTextFittingSize.height, availableContentHeight)
    let imageSide = image == nil ? 0 : availableContentHeight
    let contentWidth = imageSide + textWidth
    let availableContentWidth = max(0, bounds.width - (horizontalPadding * 2))
    let contentMinX =
      if contentWidth <= availableContentWidth {
        max(horizontalPadding, (bounds.width - contentWidth) / 2)
      } else {
        horizontalPadding
      }

    let textMinX: CGFloat
    if image == nil {
      imageRect = .zero
      textMinX = contentMinX
    } else {
      imageRect = CGRect(
        x: contentMinX,
        y: bounds.minY + ((bounds.height - imageSide) / 2),
        width: imageSide,
        height: imageSide,
      )
      textMinX = imageRect.maxX
    }

    textRect = CGRect(
      x: textMinX,
      y: bounds.minY + ((bounds.height - textHeight) / 2),
      width: min(textWidth, max(0, bounds.width - horizontalPadding - textMinX)),
      height: textHeight,
    )
  }

  public override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    let capsuleRadius = min(bounds.width, bounds.height) / 2
    let path = NSBezierPath(roundedRect: bounds, xRadius: capsuleRadius, yRadius: capsuleRadius)
    backgroundFillColor.setFill()
    path.fill()

    if isBordered {
      borderStrokeColor.setStroke()
      path.stroke()
    }

    image?.draw(rect: imageRect, tint: contentTintColor)

    if stringValue.isEmpty { return }

    NSString(string: stringValue).draw(
      with: textRect,
      options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
      attributes: [
        .font: font,
        .foregroundColor: contentTintColor,
        .paragraphStyle: Self.paragraphStyle,
      ],
      context: nil,
    )
  }

  public func accessibilityValue() -> String? {
    stringValue
  }

  public func measuredTextFittingSize() -> CGSize {
    let key = TextSizeCache.Key(
      fontName: font.fontName,
      fontSize: font.pointSize,
      string: stringValue,
      boldCharacterCount: 0,
    )
    return textSizeClient.size(key)
  }

  // MARK: Private

  @Dependency(\.textSizeClient) private var textSizeClient

  private var imageRect = CGRect.zero
  private var textRect = CGRect.zero
}

// MARK: NSAccessibilityStaticText

extension RBLabel: NSAccessibilityStaticText { }
