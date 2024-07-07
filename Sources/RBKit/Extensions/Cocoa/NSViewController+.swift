import AppKit

extension NSViewController {
  public func togglePopoverPresentation(
    _ viewController: NSViewController,
    asPopoverRelativeTo positioningRect: NSRect,
    of positioningView: NSView,
    preferredEdge: NSRectEdge,
    behavior: NSPopover.Behavior)
  {
    if let presentor = viewController.presentingViewController {
      presentor.dismiss(viewController)
    } else {
      present(
        viewController,
        asPopoverRelativeTo: positioningRect,
        of: positioningView,
        preferredEdge: preferredEdge,
        behavior: behavior)
    }
  }
}
