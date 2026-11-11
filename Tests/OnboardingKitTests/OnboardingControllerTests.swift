import AppKit
import Dependencies
import SwiftUI
import Testing

@testable import OnboardingKit

@MainActor
struct OnboardingControllerTests {
  @Test
  func `onboardIfNeeded() with user already onboarded, should return .alreadyOnboarded`() {
    let result = withDependencies { d in
      d.onboardingClient.getIsOnboarded = { true }
    } operation: {
      OnboardingController.onboardIfNeeded(
        permissions: [],
        statusItem: NSStatusItem(),
        analyticsAppID: "telemetry-app",
      )
    }

    #expect(result == .alreadyOnboarded)
  }

  @Test
  func `onboardIfNeeded() with user not onboarded, should run modal and return .didCompleteInitialOnboarding`() async {
    await confirmation { modalRunConfirmation in
      let result = withDependencies { d in
        d.onboardingClient.getIsOnboarded = { false }
        d.userDefaultsClient.bool = { _ in false }
        d.nsApplicationClient.activateIgnoringOtherApps = { _ in }
        d.nsApplicationClient.runModal = { window in
          // Verify window properties
          #expect(window.level == .normal)
          #expect(window.styleMask == [.fullSizeContentView, .titled])
          #expect(window.titlebarAppearsTransparent == true)
          #expect(window.titleVisibility == .hidden)
          #expect(window.title == "Welcome to \(Bundle.main.appName)")
          #expect(window.isReleasedWhenClosed == false)

          // Verify content view controller
          #expect(window.contentViewController != nil)
          #expect(window.contentViewController?.preferredContentSize.width == 480)
          #expect(window.contentViewController?.preferredContentSize.height == 700)

          modalRunConfirmation()
          return .OK
        }
      } operation: {
        OnboardingController.onboardIfNeeded(
          permissions: [],
          statusItem: NSStatusItem(),
          analyticsAppID: "telemetry-app",
        )
      }

      #expect(result == .didCompleteInitialOnboarding)
    }
  }

  @Test
  func `onboardIfNeeded() with custom height, should use provided height`() async {
    await confirmation { modalRunConfirmation in
      let onboardingWindowWidth: CGFloat = 640
      let customHeight: Double = 900

      _ = withDependencies { d in
        d.onboardingClient.getIsOnboarded = { false }
        d.userDefaultsClient.bool = { _ in false }
        d.nsApplicationClient.activateIgnoringOtherApps = { _ in }
        d.nsApplicationClient.runModal = { window in
          #expect(window.contentViewController?.preferredContentSize.width == onboardingWindowWidth)
          #expect(Double(window.contentViewController?.preferredContentSize.height ?? 0) == customHeight)

          modalRunConfirmation()
          return .OK
        }
      } operation: {
        OnboardingController.onboardIfNeeded(
          permissions: [],
          statusItem: NSStatusItem(),
          analyticsAppID: "telemetry-app",
          onboardingWindowWidth: onboardingWindowWidth,
          height: customHeight,
        )
      }
    }
  }

  @Test
  func `onboardIfNeeded() with injected window, should call close() on window`() async {
    // Create a custom window that tracks close() calls
    class TestWindow: NSWindow {
      var closeCalled = false

      override func close() {
        closeCalled = true
        super.close()
      }
    }

    let testWindow = TestWindow(
      contentRect: .init(origin: .zero, size: .zero),
      styleMask: [.fullSizeContentView, .titled],
      backing: .buffered,
      defer: true,
    )

    // Inject the test window
    OnboardingController.window = testWindow

    await confirmation { modalRunConfirmation in
      _ = withDependencies { d in
        d.onboardingClient.getIsOnboarded = { false }
        d.userDefaultsClient.bool = { _ in false }
        d.nsApplicationClient.activateIgnoringOtherApps = { _ in }
        d.nsApplicationClient.runModal = { window in
          // Verify we're using our injected window
          #expect(window === testWindow)
          modalRunConfirmation()
          return .OK
        }
      } operation: {
        OnboardingController.onboardIfNeeded(
          permissions: [],
          statusItem: NSStatusItem(),
          analyticsAppID: "telemetry-app",
        )
      }
    }

    // Verify close() was called
    #expect(testWindow.closeCalled == true)

    // Reset window to default for other tests
    OnboardingController.window = OnboardingController.NormalLevelWindow(
      contentRect: .init(origin: .zero, size: .zero),
      styleMask: [.fullSizeContentView, .titled],
      backing: .buffered,
      defer: true,
    )
  }

  @Test
  func `onboardIfNeeded() with nsApplicationClient dependencies should call endpoints with expected arguments`() {
    let expectedWindow = OnboardingController.window

    var activateArguments = [Bool]()
    var runModalWindow: NSWindow?
    var stopModalCallCount = 0

    let result: OnboardingResult? = withDependencies { d in
      d.onboardingClient.getIsOnboarded = { false }
      d.userDefaultsClient.bool = { _ in false }
      d.nsApplicationClient.activateIgnoringOtherApps = { ignoringOtherApps in
        activateArguments.append(ignoringOtherApps)
      }
      d.nsApplicationClient.runModal = { window in
        runModalWindow = window
        return .OK
      }
      d.nsApplicationClient.stopModal = {
        stopModalCallCount += 1
      }
    } operation: {
      OnboardingController.onboardIfNeeded(
        permissions: [],
        statusItem: NSStatusItem(),
        analyticsAppID: "telemetry-app",
      )
    }

    #expect(result == .didCompleteInitialOnboarding)
    #expect(activateArguments == [true])
    #expect(runModalWindow != nil)
    #expect(runModalWindow === expectedWindow)
    #expect(stopModalCallCount == 0)
  }

  @Test
  func `NormalLevelWindow.level with any setter value, should always return .normal`() {
    let window = OnboardingController.NormalLevelWindow(
      contentRect: .zero,
      styleMask: [],
      backing: .buffered,
      defer: true,
    )

    #expect(window.level == .normal)

    window.level = .floating
    #expect(window.level == .normal)

    window.level = .modalPanel
    #expect(window.level == .normal)
  }

}
