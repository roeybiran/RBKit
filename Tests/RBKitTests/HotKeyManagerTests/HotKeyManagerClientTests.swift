import Dependencies
@testable import RBKit
import Testing

struct HotKeyManagerClientTests {
    @Test
    func `migrateLegacyDefaults should move mapped names without overwriting ids`() throws {
        nonisolated(unsafe) var savedValue: [String: Any]?
        nonisolated(unsafe) var savedKey: String?

        withDependencies {
            $0.userDefaultsClient.dictionary = { _ in
                [
                    "openApp": [
                        String.DEFAULTS_KEY_CODE_KEY: Key.f2.keyCode,
                        String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: []).carbon,
                    ],
                    "1": [
                        String.DEFAULTS_KEY_CODE_KEY: Key.a.keyCode,
                        String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: [.command]).carbon,
                    ],
                    "closeApp": [
                        String.DEFAULTS_KEY_CODE_KEY: Key.v.keyCode,
                        String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: [.command, .control, .option, .shift]).carbon,
                    ],
                    "legacyOnly": [
                        String.DEFAULTS_KEY_CODE_KEY: Key.z.keyCode,
                        String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: []).carbon,
                    ],
                ]
            }
            $0.userDefaultsClient.setAny = { value, key in
                savedValue = value as? [String: Any]
                savedKey = key
            }
        } operation: {
            HotKeyManagerClient.migrateLegacyDefaults([
                "openApp": 1,
                "closeApp": 2,
            ])
        }

        #expect(savedKey == .DEFAULTS_ALL_HOT_KEYS_KEY)
        let migratedDefaults = try #require(savedValue)
        #expect(migratedDefaults["openApp"] == nil)
        #expect(migratedDefaults["closeApp"] == nil)
        #expect(migratedDefaults["legacyOnly"] != nil)
        #expect(
            [
                .DEFAULTS_KEY_CODE_KEY: Key.a.keyCode,
                .DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: [.command]).carbon,
            ]
                == migratedDefaults["1"] as? [String: Int]
        )
        #expect(
            [
                .DEFAULTS_KEY_CODE_KEY: Key.v.keyCode,
                .DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: [.command, .control, .option, .shift]).carbon,
            ]
                == migratedDefaults["2"] as? [String: Int]
        )
    }
}
