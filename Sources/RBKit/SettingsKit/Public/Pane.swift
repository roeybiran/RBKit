import AppKit

// MARK: - Pane

public struct Pane {
  public init(
    _ label: String,
    identifier: String,
    systemImage: String,
    viewController: NSViewController,
  ) {
    self.label = label
    self.identifier = identifier
    self.systemImage = systemImage
    self.viewController = viewController
  }

  public let label: String
  public let identifier: String
  public let systemImage: String
  public let viewController: NSViewController

}

extension NSTabViewItem {
  public convenience init(pane: Pane) {
    self.init(viewController: pane.viewController)
    label = pane.label
    identifier = pane.identifier
    image = .init(systemSymbolName: pane.systemImage, accessibilityDescription: nil)
  }
}
