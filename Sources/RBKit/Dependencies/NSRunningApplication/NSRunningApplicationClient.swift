import AppKit.NSApplication
import Dependencies
import DependenciesMacros

// MARK: - NSRunningApplicationClient

@DependencyClient
public struct NSRunningApplicationClient: Sendable {
  // MARK: - Getting running application instances
  public var initWithPID: (_ pid: pid_t) -> NSRunningApplication?
  public var runningApplications: (_ withBundleIdentifier: String) -> [NSRunningApplication] = { _ in [] }
  public var current:  @Sendable () -> NSRunningApplication = { .init() }

  // MARK: - Activating applications
  @DependencyEndpoint(method: "activate")
  public var activate:
    @Sendable (_ app: NSRunningApplication, _ options: NSApplication.ActivationOptions) -> Bool = {
      _, _ in false
    }
  @DependencyEndpoint(method: "activate")
  public var activateFromApplication:
    @Sendable (
      _ app: NSRunningApplication,
      _ fromApp: NSRunningApplication,
      _ options: NSApplication.ActivationOptions)
    -> Bool = { _, _, _ in false }

  // MARK: - Hiding and unhiding applications
  public var hide: (_ app: NSRunningApplication) -> () -> Bool = { _ in { false } }
  public var unhide: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }

  // MARK: - Application information
  public var boolObservation: (_ app: NSRunningApplication) -> (
    _ keyPath: KeyPath<NSRunningApplication, Bool>,
    _ options: NSKeyValueObservingOptions,
    _ changeHandler: @escaping (NSRunningApplication, NSKeyValueObservedChange<Bool>) -> Void) -> NSKeyValueObservation = { _ in { _, _, _ in NSObject().observe(\.hash, changeHandler: { _, _ in }) } }

  // MARK: - Terminating applications
  public var forceTerminate: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }
  public var terminate: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension NSRunningApplicationClient: DependencyKey {
  public static let liveValue = NSRunningApplicationClient(
    initWithPID: NSRunningApplication.init(processIdentifier:),
    runningApplications: NSRunningApplication.runningApplications(withBundleIdentifier:),
    current: { NSRunningApplication.current
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
    hide: NSRunningApplication.hide,
    unhide: { $0.unhide() },
    boolObservation: NSRunningApplication.observe,
    forceTerminate: { $0.forceTerminate() },
    terminate: { $0.terminate() })

  public static let testValue = NSRunningApplicationClient()
}

extension NSRunningApplicationClient {
  public func isFinishedLaunchingStream(app: NSRunningApplication, options: NSKeyValueObservingOptions = [.initial, .new]) -> AsyncStream<(NSRunningApplication, Bool)> {
    let (stream, continuation) = AsyncStream.makeStream(of: (NSRunningApplication, Bool).self)
    let observation = boolObservation(app: app)(\.isFinishedLaunching, options) { object, change in
      guard let newValue = change.newValue else { return }
      continuation.yield((object, newValue))
    }
    continuation.onTermination = { _ in
      observation.invalidate()
    }
    return stream
  }
}

extension DependencyValues {
  public var nsRunningApplicationClient: NSRunningApplicationClient {
    get { self[NSRunningApplicationClient.self] }
    set { self[NSRunningApplicationClient.self] = newValue }
  }
}
