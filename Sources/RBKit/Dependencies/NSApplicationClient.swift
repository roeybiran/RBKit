import AppKit.NSApplication
import Dependencies
import DependenciesMacros

// MARK: - NSApplicationClient

@DependencyClient
public struct NSApplicationClient {
  public var terminate: (_ sender: Any?) -> Void
  @DependencyEndpoint(method: "yieldActivation")
  public var yieldActivationTo: (_ to: NSRunningApplication) -> Void
  @DependencyEndpoint(method: "yieldActivation")
  public var yieldActivationToApplicationWithBundleIdentifier: (_ toApplicationWithBundleIdentifier: String) -> Void
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
      }
    )
  }()
  public static let testValue = Self()
}

extension DependencyValues {
  public var nsApplicationClient: NSApplicationClient {
    get { self[NSApplicationClient.self] }
    set { self[NSApplicationClient.self] = newValue }
  }
}
