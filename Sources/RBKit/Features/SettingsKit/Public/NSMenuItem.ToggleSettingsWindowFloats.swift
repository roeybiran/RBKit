import AppKit
import Dependencies

extension NSMenuItem {
  public final class ToggleSettingsWindowFloats: NSMenuItem, NSMenuItemValidation {

    // MARK: Lifecycle

    public init() {
      super.init(title: "Float Settings Window on Top", action: #selector(toggleSettingsWindowFloats(_:)), keyEquivalent: "")
      target = self
    }

    required init(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
      if menuItem === self {
        menuItem.state = userDefaultsClient.bool(forKey: .DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING) ? .on : .off
      }
      return true
    }

    // MARK: Internal

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    @objc
    func toggleSettingsWindowFloats(_: Any?) {
      let currentValue = userDefaultsClient.bool(forKey: .DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING)
      userDefaultsClient.setBool(value: !currentValue, forKey: .DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING)
    }

  }
}
