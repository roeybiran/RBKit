import AppKit

/// Hosts the selected pane's view controller.
final class SettingsDetailViewController: NSViewController {

  private(set) var currentViewController: NSViewController?

  override func loadView() {
    view = NSView()
  }

  func show(_ pane: Pane) {
    let viewController = pane.viewController
    guard viewController !== currentViewController else { return }

    if let currentViewController {
      currentViewController.view.removeFromSuperview()
      currentViewController.removeFromParent()
    }

    addChild(viewController)
    let paneView = viewController.view
    paneView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(paneView)

    // SwiftUI content honors the safe area itself, so it can scroll underneath the toolbar.
    NSLayoutConstraint.activate([
      paneView.topAnchor.constraint(equalTo: view.topAnchor),
      paneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      paneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      paneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    currentViewController = viewController
  }
}
