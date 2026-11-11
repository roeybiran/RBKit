import CustomDump
import Testing

@testable import HotKeyRecorder

struct HotKeyConfigurationTests {
  @Test
  func `init(id:title:), should default ignoreWarnings to false`() {
    expectNoDifference(
      HotKeyConfiguration(id: 1, title: "Search"),
      HotKeyConfiguration(id: 1, title: "Search", ignoreWarnings: false),
    )
  }

  @Test
  func `init(id:title:ignoreWarnings:), should preserve explicit values`() {
    expectNoDifference(
      HotKeyConfiguration(id: 42, title: "Window", ignoreWarnings: true),
      HotKeyConfiguration(id: 42, title: "Window", ignoreWarnings: true),
    )
  }
}
