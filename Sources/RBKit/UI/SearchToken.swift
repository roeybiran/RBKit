import AppKit

// MARK: - SearchToken

// https://github.com/plumhead/CocoaTextAttachmentCells

public final class SearchToken: NSTextAttachment {
  @MainActor
  public init(
    text: String,
    horizontalPadding: CGFloat = 16,
    cornerRadius: CGFloat = 4,
    horizontalMargins: CGFloat = 2,
    badgeColor: NSColor = .quaternaryLabelColor,
    textColor: NSColor = .secondaryLabelColor,
    font: NSFont = .systemFont(ofSize: NSFont.systemFontSize),
  ) {
    super.init(data: nil, ofType: nil)
    attachmentCell = BadgeCell(
      text: text,
      horizontalPadding: horizontalPadding,
      cornerRadius: cornerRadius,
      horizontalMargins: horizontalMargins,
      badgeColor: badgeColor,
      textColor: textColor,
      font: font,
    )
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - BadgeCell

private final class BadgeCell: NSTextAttachmentCell {

  // MARK: Lifecycle

  init(
    text: String,
    horizontalPadding: CGFloat,
    cornerRadius: CGFloat,
    horizontalMargins: CGFloat,
    badgeColor: NSColor,
    textColor: NSColor,
    font: NSFont,
  ) {
    let textAttributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: textColor,
      .paragraphStyle: Self.paragraphStyle,
    ]

    let attributedString = NSAttributedString(string: text, attributes: textAttributes)
    let textFrame = attributedString.boundingRect(with: .zero)
    let paddedSize = NSSize(width: textFrame.width + horizontalPadding, height: textFrame.height)

    let badge = NSImage(size: paddedSize, flipped: false) { rect in
      badgeColor.setFill()
      NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius).fill()
      attributedString.draw(in: rect)
      return true
    }

    badge.accessibilityDescription = text

    cellFontDescender = font.descender
    self.horizontalMargins = horizontalMargins

    super.init(imageCell: badge)
  }

  required init(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func cellFrame(
    for textContainer: NSTextContainer,
    proposedLineFragment lineFrag: NSRect,
    glyphPosition position: NSPoint,
    characterIndex charIndex: Int,
  ) -> NSRect {
    super.cellFrame(
      for: textContainer,
      proposedLineFragment: lineFrag,
      glyphPosition: position,
      characterIndex: charIndex,
    ).insetBy(
      dx: -horizontalMargins,
      dy: 0,
    )
  }

  override func cellBaselineOffset() -> NSPoint {
    NSPoint(x: super.cellBaselineOffset().x, y: cellFontDescender)
  }

  // MARK: Private

  private static let paragraphStyle: NSMutableParagraphStyle = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    return paragraphStyle
  }()

  private let cellFontDescender: CGFloat
  private let horizontalMargins: CGFloat

}
