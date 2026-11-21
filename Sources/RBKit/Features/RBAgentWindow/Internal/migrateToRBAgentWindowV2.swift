import Dependencies
import Foundation

/// Migrates user defaults from the legacy format to v1.0.1 format
/// - Changes DEFAULTS_KEY_PREFERRED_SCREEN from String to Int
/// - Changes defaultsKeyWindowOriginCoordinates from dictionary to separate xFraction/yFraction Double values
/// - Adds "RBCommandPaletteWindow_" prefix to all key names
func migrateToRBAgentWindowV2() {
  @Dependency(\.userDefaultsClient) var userDefaultsClient

  let legacyDefaultsKeyPreferredScreen = "preferredScreen"
  if let oldPreferredScreenValue = userDefaultsClient.string(legacyDefaultsKeyPreferredScreen) {
    let intValue =
      switch oldPreferredScreenValue {
      case "withKeyboardFocus":
        0
      case "withMouseCursor":
        1
      case "withMenuBar":
        2
      default:
        0
      }

    let newPreferredScreenKey = String.DEFAULTS_KEY_PREFERRED_SCREEN
    userDefaultsClient.setInt(intValue, newPreferredScreenKey)
    userDefaultsClient.removeObject(legacyDefaultsKeyPreferredScreen)
  }

  let legacyDefaultsKeyWindowOriginCoordinates = "windowOriginCoordinates"
  if userDefaultsClient.object(legacyDefaultsKeyWindowOriginCoordinates) != nil {
    if
      let oldCoordinates = userDefaultsClient.dictionary(legacyDefaultsKeyWindowOriginCoordinates),
      let xValue = oldCoordinates["x"] as? Double,
      let yValue = oldCoordinates["y"] as? Double
    {
      let newWindowOriginXFractionKey = String.DEFAULTS_KEY_WINDOW_ORIGIN_X_FRACTION
      let newWindowOriginYFractionKey = String.DEFAULTS_KEY_WINDOW_ORIGIN_Y_FRACTION
      userDefaultsClient.setDouble(xValue, newWindowOriginXFractionKey)
      userDefaultsClient.setDouble(yValue, newWindowOriginYFractionKey)
    }
    // Always remove the old key regardless of type or whether migration succeeded
    userDefaultsClient.removeObject(legacyDefaultsKeyWindowOriginCoordinates)
  }
}
