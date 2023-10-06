import Cocoa

open class TextAndImageTableCellView: TextTableCellView {

  // MARK: Lifecycle

  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    identifier = "\(Self.self)"
    _imageView = NSImageView()
    addSubview(_imageView!)
  }

	required public init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override var imageView: NSImageView? {
    get { _imageView }
    set { _imageView = newValue }
  }

  // MARK: Private

  private var _imageView: NSImageView?

}
