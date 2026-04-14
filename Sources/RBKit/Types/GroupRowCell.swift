import AppKit

open class GroupRowCell: NSTableCellView {

  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    identifier = .init("\(Self.self)")
    let textField = NSTextField(labelWithString: "")
    textField.lineBreakMode = .byTruncatingMiddle
    textField.frame = bounds
    textField.autoresizingMask = [.width, .height]
    addSubview(textField)

    self.textField = textField
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
