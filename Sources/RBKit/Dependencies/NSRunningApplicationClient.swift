import AppKit.NSApplication
import Dependencies
import DependenciesMacros

// MARK: - NSApplicationClient

@DependencyClient
public struct NSRunningApplicationClient {
  public var runningApplications: (_ withBundleIdentifier: String) -> [NSRunningApplication] = { _ in [] }
  
  public var current: () -> NSRunningApplication = { .init() }

  @DependencyEndpoint(method: "activate")
  public var activate: (_ app: NSRunningApplication, _ options: NSApplication.ActivationOptions) -> Bool = { _, _ in false }
  
  @DependencyEndpoint(method: "activate")
  public var activateFromApplication: (_ app: NSRunningApplication, _ fromApp: NSRunningApplication, _ options: NSApplication.ActivationOptions) -> Bool = { _, _, _ in false }

  public var forceTerminate: (_ app: NSRunningApplication) -> Bool = { _ in false }

  public var terminate: (_ app: NSRunningApplication) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension NSRunningApplicationClient: DependencyKey {
  public static let liveValue = NSRunningApplicationClient(
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
    forceTerminate: { $0.forceTerminate() },
    terminate: { $0.terminate() }
  )
  public static let testValue = NSRunningApplicationClient()
}

extension DependencyValues {
  public var nsRunningApplicationClient: NSRunningApplicationClient {
    get { self[NSRunningApplicationClient.self] }
    set { self[NSRunningApplicationClient.self] = newValue }
  }
}
