import Sharing

// MARK: - RBAgentWindow Constants

extension String {
  static let USER_DEFAULTS_KEY_PREFIX = "RBCommandPaletteWindow_"
  static let DEFAULTS_KEY_PREFERRED_SCREEN = "\(USER_DEFAULTS_KEY_PREFIX)preferredScreen"
  static let DEFAULTS_KEY_WINDOW_ORIGIN_X_FRACTION = "\(USER_DEFAULTS_KEY_PREFIX)windowOriginXFraction"
  static let DEFAULTS_KEY_WINDOW_ORIGIN_Y_FRACTION = "\(USER_DEFAULTS_KEY_PREFIX)windowOriginYFraction"
}

extension SharedKey where Self == AppStorageKey<PreferredScreen>.Default {
  static var rbAgentWindowPreferredScreen: Self {
    Self[.appStorage(.DEFAULTS_KEY_PREFERRED_SCREEN), default: .withKeyboardFocus]
  }
}

extension SharedKey where Self == AppStorageKey<Double>.Default {
  static var rbAgentWindowOriginXFraction: Self {
    Self[.appStorage(.DEFAULTS_KEY_WINDOW_ORIGIN_X_FRACTION), default: 0]
  }

  static var rbAgentWindowOriginYFraction: Self {
    Self[.appStorage(.DEFAULTS_KEY_WINDOW_ORIGIN_Y_FRACTION), default: 0]
  }
}
