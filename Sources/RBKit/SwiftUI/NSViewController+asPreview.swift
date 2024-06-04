import SwiftUI

extension NSViewController {

  // MARK: Lifecycle

  public convenience init(nib: NSViewController.Type, bundle: Bundle? = nil) {
    self.init(nibName: String(describing: nib), bundle: bundle)
  }

  // MARK: Public

  public func asPreview() -> some View {
    Preview(viewController: self)
  }

  // MARK: Private

  private struct Preview: NSViewControllerRepresentable {
    var viewController: NSViewController

    func makeNSViewController(context _: Context) -> NSViewController {
      viewController
    }

    func updateNSViewController(_: NSViewController, context _: Context) { }
  }
}
