import Cocoa

extension NSTextField {
  public static func label(
    _ text: String,
    wrapping: Bool = true,
    preferredMaxLayoutWidth: CGFloat? = nil,
    color: NSColor? = .secondaryLabelColor)
    -> NSTextField
  {
    let textField: NSTextField
    if wrapping {
      textField = NSTextField(wrappingLabelWithString: text)
      textField.isSelectable = false
      textField.preferredMaxLayoutWidth = preferredMaxLayoutWidth ?? textField.preferredMaxLayoutWidth
    } else {
      textField = NSTextField(labelWithString: text)
    }
    textField.textColor = color
    return textField
  }
}
