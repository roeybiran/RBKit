@preconcurrency import AppKit.NSApplication
import Dependencies
import DependenciesMacros

// MARK: - NSApplicationClient

@DependencyClient
public struct NSApplicationClient: Sendable {
  /// Terminating the App
  public var terminate: @Sendable @MainActor (_ sender: Any?) -> Void

  /// Activating and Deactivating the App
  public var activate: @Sendable @MainActor () -> Void
  
  @DependencyEndpoint(method: "activate")
  public var activateIgnoringOtherApps: @Sendable @MainActor (_ ignoringOtherApps: Bool) -> Void

  @DependencyEndpoint(method: "yieldActivation")
  public var yieldActivationTo: @Sendable @MainActor (_ to: NSRunningApplication) -> Void

  @DependencyEndpoint(method: "yieldActivation")
  public var yieldActivationToApplicationWithBundleIdentifier:
    @Sendable @MainActor (_ toApplicationWithBundleIdentifier: String) -> Void

  /// Managing Windows, Panels, and Menus
  public var runModal: @MainActor @Sendable (_ window: NSWindow) -> NSApplication.ModalResponse = {
    _ in .OK
  }

  public var stopModal: @MainActor @Sendable () -> Void

  ///
  public var activationPolicy: @MainActor @Sendable () -> NSApplication.ActivationPolicy = {
    .prohibited
  }

  public var setActivationPolicy:
    @MainActor @Sendable (_ activationPolicy: NSApplication.ActivationPolicy) -> Bool = { _ in false
    }
}

// MARK: DependencyKey

extension NSApplicationClient: DependencyKey {
  public static let liveValue = Self(
    terminate: NSApplication.shared.terminate,
    activate: {
      if #available(macOS 14.0, *) {
        NSApplication.shared.activate()
      } else {
        NSApplication.shared.activate(ignoringOtherApps: false)
      }
    },
    activateIgnoringOtherApps: NSApplication.shared.activate(ignoringOtherApps:),
    yieldActivationTo: { app in
      if #available(macOS 14.0, *) {
        NSApplication.shared.yieldActivation(to: app)
      } else {
        // Fallback on earlier versions
      }
    },
    yieldActivationToApplicationWithBundleIdentifier: { bundleID in
      if #available(macOS 14.0, *) {
        NSApplication.shared.yieldActivation(toApplicationWithBundleIdentifier: bundleID)
      } else {
        // Fallback on earlier versions
      }
    },
    runModal: NSApplication.shared.runModal(for:),
    stopModal: NSApplication.shared.stopModal,
    activationPolicy: NSApplication.shared.activationPolicy,
    setActivationPolicy: NSApplication.shared.setActivationPolicy
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsApplicationClient: NSApplicationClient {
    get { self[NSApplicationClient.self] }
    set { self[NSApplicationClient.self] = newValue }
  }
}
