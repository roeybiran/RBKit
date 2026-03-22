import AppKit.NSScreen
import Testing

@testable import RBKit

@MainActor
struct NSScreenClientTests {
  @Test
  func `liveValue.screens(), should return current screens`() throws {
    let expectedScreens = NSScreen.screens.map(Screen.init)
    let actualScreens = NSScreenClient.liveValue.screens()

    #expect(actualScreens.map(\.localizedName) == expectedScreens.map(\.localizedName))
    #expect(actualScreens.map(\.frame) == expectedScreens.map(\.frame))
    #expect(actualScreens.map(\.visibleFrame) == expectedScreens.map(\.visibleFrame))
    #expect(actualScreens.map(\.backingScaleFactor) == expectedScreens.map(\.backingScaleFactor))
    #expect(
      actualScreens.map(\.deviceDescription.cgDirectDisplayID)
        == expectedScreens.map(\.deviceDescription.cgDirectDisplayID)
    )
  }
}
