import AppKit.NSWorkspace
import Dependencies
import DependenciesMacros
import UniformTypeIdentifiers

// MARK: - NSWorkspaceClient

// https://www.donnywals.com/building-an-asyncsequence-with-asyncstream-makestream/
// https://gist.github.com/ole/fc5c1f4c763d28d9ba70940512e81916

@DependencyClient
public struct NSWorkspaceClient {
  public var notificationCenter: () -> NotificationCenterClient = { .testValue }
  public var iconForFile: (_ fullPath: String) -> NSImage = { _ in .init() }
  public var iconFor: (_ contentType: UTType) -> NSImage = { _ in .init() }
  public var open: (_ url: URL) -> Bool = { _ in false }
  public var frontmostApplication: () -> NSRunningApplication? = { nil }
  @DependencyEndpoint(method: "frontmostApplication")
  public var frontmostApplicationObservation: (_ options: NSKeyValueObservingOptions) -> AsyncStream<NSKeyValueObservedChange<NSRunningApplication?>> = { _ in .finished }
  public var runningApplications: () -> [NSRunningApplication] = { [] }
  @DependencyEndpoint(method: "runningApplications")
  public var runningApplicationsObservation: (_ options: NSKeyValueObservingOptions) -> AsyncStream<NSKeyValueObservedChange<[NSRunningApplication]>> = { _ in .finished }
  public var menuBarOwningApplication: () -> NSRunningApplication?
  @DependencyEndpoint(method: "menuBarOwningApplication")
  public var menuBarOwningApplicationObservation: (_ options: NSKeyValueObservingOptions) -> AsyncStream<NSKeyValueObservedChange<NSRunningApplication?>> = { _ in .finished }
}

extension NotificationCenterClient {
  static let nsWorkspace: NotificationCenterClient = {
    let instance = NSWorkspace.shared.notificationCenter
    return Self(
      post: instance.post,
      notifications: instance.notifications
    )
  }()
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {
  public static let liveValue: Self = {
    let instance = NSWorkspace.shared
    let client = NSWorkspaceClient.liveValue

    func toStream<Value>(
      options: NSKeyValueObservingOptions,
      keyPath: KeyPath<NSWorkspace, Value>) -> AsyncStream<NSKeyValueObservedChange<Value>>
    {
      let (stream, continuation) = AsyncStream.makeStream(of: NSKeyValueObservedChange<Value>.self)
      let observation = instance.observe(keyPath, options: options) { _, change in
        continuation.yield(change)
      }
      continuation.onTermination = { _ in
        observation.invalidate()
      }
      return stream
    }

    return Self(
      notificationCenter: { .nsWorkspace },
      iconForFile: NSWorkspace.shared.icon(forFile:),
      iconFor: NSWorkspace.shared.icon(for:),
      open: NSWorkspace.shared.open,
      frontmostApplication: { NSWorkspace.shared.frontmostApplication },
      frontmostApplicationObservation: { toStream(options: $0, keyPath: \.frontmostApplication) },
      runningApplications: { NSWorkspace.shared.runningApplications },
      runningApplicationsObservation: { toStream(options: $0, keyPath: \.runningApplications) },
      menuBarOwningApplication: { NSWorkspace.shared.menuBarOwningApplication },
      menuBarOwningApplicationObservation: { toStream(options: $0, keyPath: \.menuBarOwningApplication) }
    )
  }()

  public static let testValue = NSWorkspaceClient()
}

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
