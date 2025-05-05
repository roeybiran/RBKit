import AppKit

open class TextTableCellView: NSTableCellView {

  // MARK: Lifecycle

  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    identifier = "\(Self.self)"
    _textField = NSTextField(labelWithString: "")
    _textField?.textColor = .controlTextColor
    _textField?.backgroundColor = .controlColor
    addSubview(_textField!)
  }

  required public init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override var textField: NSTextField? {
    get { _textField }
    set { _textField = newValue }
  }

  // MARK: Private

  private var _textField: NSTextField?

}
