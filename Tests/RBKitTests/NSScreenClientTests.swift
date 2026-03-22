import AppKit
import Dependencies
import Testing

@testable import RBKit

@MainActor
struct NSScreenClientTests {
  @Test
  func `liveValue.screens(), should emit current screens immediately and after screen parameters change`() async throws {
    nonisolated(unsafe) var emissions = [[Screen]]()
    let notificationCenter = NotificationCenter()
    let expectedScreens = NSScreen.screens.map(Screen.init)

    await withDependencies {
      $0.notificationCenter = notificationCenter
    } operation: {
      let client = NSScreenClient.liveValue

      Task {
        for await screens in client.screens() {
          emissions.append(screens)
          if emissions.count == 2 {
            break
          }
        }
      }

      try? await Task.sleep(for: .milliseconds(10))
      notificationCenter.post(name: NSApplication.didChangeScreenParametersNotification, object: nil)
      try? await Task.sleep(for: .milliseconds(10))
    }

    let first = try #require(emissions.first)
    let second = try #require(emissions.dropFirst().first)

    #expect(first.map(\.localizedName) == expectedScreens.map(\.localizedName))
    #expect(second.map(\.localizedName) == expectedScreens.map(\.localizedName))
    #expect(first.map(\.frame) == expectedScreens.map(\.frame))
    #expect(second.map(\.frame) == expectedScreens.map(\.frame))
    #expect(first.map(\.visibleFrame) == expectedScreens.map(\.visibleFrame))
    #expect(second.map(\.visibleFrame) == expectedScreens.map(\.visibleFrame))
    #expect(first.map(\.backingScaleFactor) == expectedScreens.map(\.backingScaleFactor))
    #expect(second.map(\.backingScaleFactor) == expectedScreens.map(\.backingScaleFactor))
    #expect(
      first.map(\.deviceDescription.cgDirectDisplayID)
        == expectedScreens.map(\.deviceDescription.cgDirectDisplayID)
    )
    #expect(
      second.map(\.deviceDescription.cgDirectDisplayID)
        == expectedScreens.map(\.deviceDescription.cgDirectDisplayID)
    )
  }
}
