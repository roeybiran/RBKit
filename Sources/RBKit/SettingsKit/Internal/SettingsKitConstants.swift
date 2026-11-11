import Sharing

// MARK: - SettingsKit Constants

extension String {
  static let DEFAULTS_KEY_PREFIX = "RBSettingsKit_"
  static let DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING = "\(DEFAULTS_KEY_PREFIX)isWindowFloating"
  static let DEFAULTS_KEY_LAST_TAB_INDEX = "\(DEFAULTS_KEY_PREFIX)selectedTab"
}

extension SharedKey where Self == AppStorageKey<Bool>.Default {
  static var isSettingsWindowFloating: Self {
    Self[.appStorage(.DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING), default: false]
  }
}

extension SharedKey where Self == AppStorageKey<Int>.Default {
  static var settingsWindowLastTabIndex: Self {
    Self[.appStorage(.DEFAULTS_KEY_LAST_TAB_INDEX), default: 0]
  }
}
