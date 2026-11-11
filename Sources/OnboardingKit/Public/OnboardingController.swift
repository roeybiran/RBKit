import AppKit
import ComposableArchitecture
import Dependencies
import Foundation
import PermissionsKit
import SwiftUI

// MARK: - OnboardingController

public enum OnboardingController {

  // MARK: Public

  @MainActor
  @discardableResult
  public static func onboardIfNeeded(
    permissions: [Permission],
    statusItem: NSStatusItem,
    analyticsAppID: String,
    onboardingWindowWidth: CGFloat = 480,
    height: Double = 700,
    customView: some View = EmptyView(),
  ) -> OnboardingResult {
    @Dependency(\.onboardingClient) var onboardingClient
    @Dependency(\.nsApplicationClient) var nsApplicationClient

    if onboardingClient.getIsOnboarded() { return .alreadyOnboarded }

    let store = Store(
      initialState: OnboardingFeature.State(permissions: permissions)
    ) {
      OnboardingFeature()
    }

    let hostingController = NSHostingController(
      rootView: OnboardingView(
        store: store,
        statusItem: statusItem,
        analyticsAppID: analyticsAppID,
        customView: customView,
      )
      .scrollDisabled(true)
    )

    hostingController.preferredContentSize = .init(
      width: onboardingWindowWidth,
      height: CGFloat(height),
    )
    window.contentViewController = hostingController
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    window.title = "Welcome to \(Bundle.main.appName)"
    window.isReleasedWhenClosed = false

    nsApplicationClient.activate(ignoringOtherApps: true)

    _ = nsApplicationClient.runModal(window: window)

    window.close()

    return .didCompleteInitialOnboarding
  }

  // MARK: Internal

  final class NormalLevelWindow: NSWindow {
    override var level: NSWindow.Level {
      get { .normal }
      set { }
    }
  }

  @MainActor static var window: NSWindow = NormalLevelWindow(
    contentRect: .init(origin: .zero, size: .zero),
    styleMask: [.fullSizeContentView, .titled],
    backing: .buffered,
    defer: true,
  )

}
