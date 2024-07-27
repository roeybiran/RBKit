import SwiftUI

extension NSView {

  // MARK: Public

  public func asPreview() -> some View {
    Preview(view: self)
  }

  // MARK: Private

  private struct Preview: NSViewRepresentable {
    let view: NSView

    func makeNSView(context _: Context) -> NSView {
      view
    }

    func updateNSView(_: NSView, context _: Context) { }
  }
}
