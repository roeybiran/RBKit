import AppKit

extension NSMenuItem {
  public final class CheckForUpdates: NSMenuItem {

    public init() {
      super.init(
        title: .defaultMenuItemTitle,
        action: #selector(SparkleController.checkForUpdates(_:)),
        keyEquivalent: "",
      )
      target = SparkleController.shared
    }

    required init(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}
