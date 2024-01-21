import AppKit

open class ProgrammaticCollectionViewItem: NSCollectionViewItem {

  // MARK: Open

  override open var imageView: NSImageView? {
    get { _imageView }
    set { _imageView = newValue }
  }

  override open var textField: NSTextField? {
    get { _textField }
    set { _textField = newValue }
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
  }

  override open func loadView() {
    view = NSView()
  }

  // MARK: Private

  private var _imageView: NSImageView? = NSImageView()
  private var _textField: NSTextField? = NSTextField(labelWithString: "")

}
