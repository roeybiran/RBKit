import Cocoa

extension [NSAttributedString.Key: Any] {
  @MainActor public static let textHighlightingParagraphStyle: Self = {
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .byTruncatingMiddle
    return [.paragraphStyle: style]
  }()

  @MainActor public static let textHighlightingFontStyle: Self = [
    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .bold),
    .underlineStyle: NSUnderlineStyle.single.rawValue, // we have to use rawValue here!
  ]
}
