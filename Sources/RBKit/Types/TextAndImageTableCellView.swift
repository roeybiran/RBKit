import AppKit

open class TextAndImageTableCellView: TextTableCellView {

  // MARK: Lifecycle

  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    identifier = .init("\(Self.self)")
    _imageView = NSImageView()
    addSubview(_imageView!)
  }

  required public init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  open override var imageView: NSImageView? {
    get { _imageView }
    set { _imageView = newValue }
  }

  // MARK: Private

  private var _imageView: NSImageView?
}
