import AppKit.NSApplication
import Dependencies
import DependenciesMacros

// MARK: - NSApplicationClient

@DependencyClient
public struct NSApplicationClient {
  /// Terminating the App
  public var terminate: (_ sender: Any?) -> Void

  /// Activating and Deactivating the App
  @DependencyEndpoint(method: "yieldActivation")
  public var yieldActivationTo: (_ to: NSRunningApplication) -> Void
  @DependencyEndpoint(method: "yieldActivation")
  public var yieldActivationToApplicationWithBundleIdentifier: (_ toApplicationWithBundleIdentifier: String) -> Void

  /// Managing Windows, Panels, and Menus
  public var runModal: (_ window: NSWindow) -> NSApplication.ModalResponse = { _ in .OK }
  public var stopModal: () -> Void

  //
  public var activationPolicy: () -> NSApplication.ActivationPolicy = { .prohibited }
  public var setActivationPolicy: (_ activationPolicy: NSApplication.ActivationPolicy) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension NSApplicationClient: DependencyKey {
  public static let liveValue: Self = {
    let instance = NSApplication.shared
    return Self(
      terminate: { sender in
        instance.terminate(sender)
      },
      yieldActivationTo: { app in
        if #available(macOS 14.0, *) {
          instance.yieldActivation(to: app)
        } else {
          // Fallback on earlier versions
        }
      },
      yieldActivationToApplicationWithBundleIdentifier: { bundleID in
        if #available(macOS 14.0, *) {
          instance.yieldActivation(toApplicationWithBundleIdentifier: bundleID)
        } else {
          // Fallback on earlier versions
        }
      },
      runModal: instance.runModal(for:),
      stopModal: instance.stopModal,
      activationPolicy: instance.activationPolicy,
      setActivationPolicy: instance.setActivationPolicy)
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsApplicationClient: NSApplicationClient {
    get { self[NSApplicationClient.self] }
    set { self[NSApplicationClient.self] = newValue }
  }
}
