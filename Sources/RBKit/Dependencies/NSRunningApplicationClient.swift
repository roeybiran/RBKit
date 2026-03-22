@preconcurrency
import AppKit.NSApplication
import Dependencies
import DependenciesMacros

// MARK: - NSRunningApplicationClient

@DependencyClient
public struct NSRunningApplicationClient: Sendable {
  public var initWithPID: @Sendable (_ pid: pid_t) -> NSRunningApplication?
  public var runningApplications: @Sendable (_ withBundleIdentifier: String) -> [NSRunningApplication] = { _ in [] }
  public var current: @Sendable () -> NSRunningApplication = { .init() }

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
      _ options: NSApplication.ActivationOptions,
    ) -> Bool = { _, _, _ in false }

  public var hide: @Sendable (_ app: NSRunningApplication) -> () -> Bool = { _ in { false } }
  public var unhide: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }

  @DependencyEndpoint(method: "changes")
  public var boolChanges: @Sendable @MainActor (
    _ app: NSRunningApplication,
    _ keyPath: KeyPath<NSRunningApplication, Bool>,
    _ options: NSKeyValueObservingOptions
  ) -> AsyncStream<KeyValueObservedChange<Bool>> = { _, _, _ in
    .finished
  }

  @DependencyEndpoint(method: "changes")
  public var activationPolicyChanges: @Sendable @MainActor (
    _ app: NSRunningApplication,
    _ keyPath: KeyPath<NSRunningApplication, NSApplication.ActivationPolicy>,
    _ options: NSKeyValueObservingOptions
  ) -> AsyncStream<KeyValueObservedChange<NSApplication.ActivationPolicy>> = { _, _, _ in
    .finished
  }

  public var forceTerminate: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }
  public var terminate: @Sendable (_ app: NSRunningApplication) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension NSRunningApplicationClient: DependencyKey {
  public static let liveValue = NSRunningApplicationClient(
    initWithPID: { NSRunningApplication(processIdentifier: $0) },
    runningApplications: { NSRunningApplication.runningApplications(withBundleIdentifier: $0) },
    current: { NSRunningApplication.current },
    activate: { $0.activate(options: $1) },
    activateFromApplication: { app, fromApp, options in
      app.activate(from: fromApp, options: options)
    },
    hide: { app in
      { app.hide() }
    },
    unhide: { $0.unhide() },
    boolChanges: { keyPathApp, keyPath, options in
      keyValueChangeStream(
        observed: keyPathApp,
        keyPath: keyPath,
        options: options,
      )
    },
    activationPolicyChanges: { keyPathApp, keyPath, options in
      keyValueChangeStream(
        observed: keyPathApp,
        keyPath: keyPath,
        options: options,
      )
    },
    forceTerminate: { $0.forceTerminate() },
    terminate: { $0.terminate() },
  )

  public static let testValue = NSRunningApplicationClient()
}

extension DependencyValues {
  public var nsRunningApplicationClient: NSRunningApplicationClient {
    get { self[NSRunningApplicationClient.self] }
    set { self[NSRunningApplicationClient.self] = newValue }
  }
}
