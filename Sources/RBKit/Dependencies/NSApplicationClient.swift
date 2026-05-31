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

  public var currentEvent: @MainActor @Sendable () -> NSEvent?

  public var currentAppearance: @MainActor @Sendable () -> NSAppearance = {
    NSAppearance(named: .aqua)!
  }

  public var currentAppearanceObservation: @MainActor @Sendable () -> AsyncStream<Void> = {
    AsyncStream { $0.finish() }
  }
}

// MARK: DependencyKey

extension NSApplicationClient: DependencyKey {
  public static let liveValue = Self(
    terminate: { NSApplication.shared.terminate($0) },
    activate: { NSApplication.shared.activate() },
    activateIgnoringOtherApps: { NSApplication.shared.activate(ignoringOtherApps: $0) },
    yieldActivationTo: { NSApplication.shared.yieldActivation(to: $0) },
    yieldActivationToApplicationWithBundleIdentifier: {
      NSApplication.shared.yieldActivation(toApplicationWithBundleIdentifier: $0)
    },
    runModal: { NSApplication.shared.runModal(for: $0) },
    stopModal: { NSApplication.shared.stopModal() },
    activationPolicy: { NSApplication.shared.activationPolicy() },
    setActivationPolicy: { NSApplication.shared.setActivationPolicy($0) },
    currentEvent: { NSApplication.shared.currentEvent },
    currentAppearance: { NSApplication.shared.effectiveAppearance },
    currentAppearanceObservation: {
      AsyncStream { continuation in
        let observation = NSApplicationAppearanceObservation(continuation: continuation)
        continuation.onTermination = { _ in
          Task {
            await observation.invalidate()
          }
        }
      }
    },
  )

  public static let testValue = Self()
}

// MARK: - NSApplicationAppearanceObservation

@MainActor
private final class NSApplicationAppearanceObservation {

  // MARK: Lifecycle

  init(continuation: AsyncStream<Void>.Continuation) {
    observation = NSApplication.shared.observe(\.effectiveAppearance, options: [.initial, .new]) { app, _ in
      app.effectiveAppearance.performAsCurrentDrawingAppearance {
        continuation.yield()
      }
    }
  }

  // MARK: Internal

  func invalidate() {
    observation?.invalidate()
    observation = nil
  }

  // MARK: Private

  private var observation: NSKeyValueObservation?
}

extension DependencyValues {
  public var nsApplicationClient: NSApplicationClient {
    get { self[NSApplicationClient.self] }
    set { self[NSApplicationClient.self] = newValue }
  }
}
