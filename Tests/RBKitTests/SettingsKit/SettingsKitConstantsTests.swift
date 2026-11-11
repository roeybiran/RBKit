import Testing
@testable import RBKit

struct SettingsKitConstantsTests {
  @Test
  func `UserDefaults keys should use shared prefix and lower camel case names`() {
    #expect(String.DEFAULTS_KEY_PREFIX == "RBSettingsKit_")
    #expect(String.DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING == "RBSettingsKit_isWindowFloating")
    #expect(String.DEFAULTS_KEY_LAST_TAB_INDEX == "RBSettingsKit_selectedTab")
  }
}
