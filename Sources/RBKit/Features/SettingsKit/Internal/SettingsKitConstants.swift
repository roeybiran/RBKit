import Sharing

// MARK: - SettingsKit Constants

extension String {
  static let DEFAULTS_KEY_PREFIX = "RBSettingsKit_"
  static let DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING = "\(DEFAULTS_KEY_PREFIX)isWindowFloating"
  static let DEFAULTS_KEY_LAST_PANE_IDENTIFIER = "\(DEFAULTS_KEY_PREFIX)selectedPane"
}

extension SharedKey where Self == AppStorageKey<Bool>.Default {
  static var isSettingsWindowFloating: Self {
    Self[.appStorage(.DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING), default: false]
  }
}

extension SharedKey where Self == AppStorageKey<String?> {
  static var settingsWindowLastPaneIdentifier: Self {
    .appStorage(.DEFAULTS_KEY_LAST_PANE_IDENTIFIER)
  }
}
