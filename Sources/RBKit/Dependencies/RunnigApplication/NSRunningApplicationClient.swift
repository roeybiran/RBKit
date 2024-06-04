import AppKit.NSApplication
import Dependencies
import DependenciesMacros

// MARK: - NSRunningApplicationClient

@DependencyClient
public struct NSRunningApplicationClient {
  // Getting running application instances
  public var make: (_ pid: pid_t) -> NSRunningApplication?
  public var runningApplications: (_ withBundleIdentifier: String) -> [NSRunningApplication] = { _ in [] }
  public var current: () -> NSRunningApplication = { .init() }
  /// Activating applications
  @DependencyEndpoint(method: "activate")
  public var activate: (_ app: NSRunningApplication, _ options: NSApplication.ActivationOptions) -> Bool = { _, _ in false }
  @DependencyEndpoint(method: "activate")
  public var activateFromApplication: (
    _ app: NSRunningApplication,
    _ fromApp: NSRunningApplication,
    _ options: NSApplication.ActivationOptions)
    -> Bool = { _, _, _ in false }
  // Hiding and unhiding applications
  public var hide: (_ app: NSRunningApplication) -> Bool = { _ in false }
  public var unhide: (_ app: NSRunningApplication) -> Bool = { _ in false }
  // Terminating applications
  public var forceTerminate: (_ app: NSRunningApplication) -> Bool = { _ in false }
  public var terminate: (_ app: NSRunningApplication) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension NSRunningApplicationClient: DependencyKey {
  public static let liveValue = NSRunningApplicationClient(
    make: NSRunningApplication.init,
    runningApplications: NSRunningApplication.runningApplications,
    current: { NSRunningApplication.current },
    activate: { app, options in
      app.activate(options: options)
    },
    activateFromApplication: { app, fromApp, options in
      if #available(macOS 14.0, *) {
        app.activate(from: fromApp, options: options)
      } else {
        app.activate(options: options)
      }
    },
    hide: { $0.hide() },
    unhide: { $0.unhide() },
    forceTerminate: { $0.forceTerminate() },
    terminate: { $0.terminate() })
  public static let testValue = NSRunningApplicationClient()
}

extension DependencyValues {
  public var nsRunningApplicationClient: NSRunningApplicationClient {
    get { self[NSRunningApplicationClient.self] }
    set { self[NSRunningApplicationClient.self] = newValue }
  }
}
