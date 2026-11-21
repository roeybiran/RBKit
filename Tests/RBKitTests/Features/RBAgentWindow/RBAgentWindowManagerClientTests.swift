import Dependencies
import Foundation
import Sharing
import Testing

@testable import RBKit

// MARK: - RBAgentWindowManagerClientTests

@MainActor
struct RBAgentWindowManagerClientTests {

  @Test
  func `liveValue should create client accessing underlying manager`() {
    nonisolated(unsafe) var getPreferredScreenCalled = false
    nonisolated(unsafe) var migrationCalled = false
    @Shared(.rbAgentWindowOriginXFraction) var windowOriginXFraction = 0.5
    @Shared(.rbAgentWindowOriginYFraction) var windowOriginYFraction = 0.5

    withDependencies { d in
      d.screenClient.main = {
        getPreferredScreenCalled = true
        return Screen.mock(x: 0, y: 0, w: 1920, h: 1080)
      }
      d.screenClient.screens = { [Screen.mock(x: 0, y: 0, w: 1920, h: 1080)] }
      d.nsEventClient.mouseLocation = { CGPoint(x: 960, y: 540) }
      d.userDefaultsClient.string = { key in
        if key == "preferredScreen" {
          migrationCalled = true
        }
        return nil
      }
      d.userDefaultsClient.dictionary = { _ in nil }
      d.userDefaultsClient.object = { _ in nil }
      d.userDefaultsClient.setInt = { _, _ in }
      d.userDefaultsClient.removeObject = { _ in }
    } operation: {
      let client = RBAgentWindowManagerClient.liveValue

      _ = client.getPreferredScreen()
      let testFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
      let testScreen = Screen.mock(x: 0, y: 0, w: 1920, h: 1080)
      client.setTopLeftPoint(testFrame, testScreen)
      let topLeftPoint = client.getTopLeftPoint(testFrame)

      #expect(windowOriginXFraction == 0.026041666666666668)
      #expect(windowOriginYFraction == 0.9074074074074074)
      #expect(topLeftPoint == CGPoint(x: 0, y: 100))
    }

    #expect(getPreferredScreenCalled)
    #expect(migrationCalled)
  }

  @Test
  func `migration should call string with legacy preferredScreen key`() {
    nonisolated(unsafe) var legacyPreferredScreenKeyCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { key in
        if key == "preferredScreen" {
          legacyPreferredScreenKeyCalled = true
        }
        return nil
      }
      d.userDefaultsClient.dictionary = { _ in nil }
      d.userDefaultsClient.object = { _ in nil }
      d.userDefaultsClient.setInt = { _, _ in }
      d.userDefaultsClient.removeObject = { _ in }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    #expect(legacyPreferredScreenKeyCalled)
  }
}
