import AppKit.NSApplication
import Dependencies
import DependenciesMacros

// MARK: - NSRunningApplicationClient

@DependencyClient
public struct NSRunningApplicationClient: Sendable {
  // MARK: - Getting running application instances

  public var make: @Sendable (_ pid: pid_t) -> NSRunningApplication?

  public var runningApplications: @Sendable (_ withBundleIdentifier: String) -> [NSRunningApplication] = { _ in [] }

  public var current: @Sendable () -> NSRunningApplication = { .init() }

  // MARK: - Activating applications

  @DependencyEndpoint(method: "activate")
  public var activate: @Sendable (_ app: NSRunningApplication, _ options: NSApplication.ActivationOptions) -> Bool = { _, _ in false }

  @DependencyEndpoint(method: "activate")
  public var activateFromApplication: @Sendable (
    _ app: NSRunningApplication,
    _ fromApp: NSRunningApplication,
    _ options: NSApplication.ActivationOptions)
    -> Bool = { _, _, _ in false }

  // MARK: - Hiding and unhiding applications

  public var hide: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }

  public var unhide: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }

  // MARK: - Terminating applications

  public var forceTerminate: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }

  public var terminate: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension NSRunningApplicationClient: DependencyKey {
  public static let liveValue = NSRunningApplicationClient(
    make: { NSRunningApplication(processIdentifier: $0) },
    runningApplications: { NSRunningApplication.runningApplications(withBundleIdentifier: $0) },
    current: {
      NSRunningApplication.current
    },
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
