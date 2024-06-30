import AppKit.NSWorkspace
import Dependencies
import DependenciesMacros
import UniformTypeIdentifiers

// MARK: - NSWorkspaceClient

// https://www.donnywals.com/building-an-asyncsequence-with-asyncstream-makestream/
// https://gist.github.com/ole/fc5c1f4c763d28d9ba70940512e81916

@DependencyClient
public struct NSWorkspaceClient {
  // public var notificationCenter: () -> NotificationCenterClient = { .testValue }

  public var iconForFile: (_ fullPath: String) -> NSImage = { _ in .init() }
  public var iconFor: (_ contentType: UTType) -> NSImage = { _ in .init() }
  public var open: (_ url: URL) -> Bool = { _ in false }
  public var frontmostApplication: () -> NSRunningApplication? = { nil }
  @DependencyEndpoint(method: "frontmostApplication")
  public var frontmostApplicationObservation: (_ options: NSKeyValueObservingOptions)
    -> AsyncStream<KeyValueObservedChange<NSRunningApplication?>> = { _ in .finished }
  public var runningApplications: () -> [NSRunningApplication] = { [] }
  @DependencyEndpoint(method: "runningApplications")
  public var runningApplicationsObservation: (_ options: NSKeyValueObservingOptions)
    -> AsyncStream<KeyValueObservedChange<[NSRunningApplication]>> = { _ in .finished }
  public var menuBarOwningApplication: () -> NSRunningApplication?
  @DependencyEndpoint(method: "menuBarOwningApplication")
  public var menuBarOwningApplicationObservation: (_ options: NSKeyValueObservingOptions)
    -> AsyncStream<KeyValueObservedChange<NSRunningApplication?>> = { _ in .finished }
  ///
  public var notifications: (_ named: Notification.Name, _ object: AnyObject?) -> AsyncStream<Notification> = { _, _ in
    .finished
  }
}

// MARK: DependencyKey

// extension NotificationCenterClient {
//  static let nsWorkspace: NotificationCenterClient = {
//    let instance = NSWorkspace.shared.notificationCenter
//    let k = NSWorkspace.shared.notificationCenter.notifications(named: NSWorkspace.willLaunchApplicationNotification, object: nil).eraseToStream()
//    return Self(
//      post: instance.post,
//      notifications: instance.notifications)
//  }()
// }

extension NSWorkspaceClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    // notificationCenter: { .nsWorkspace },
    iconForFile: NSWorkspace.shared.icon(forFile:),
    iconFor: NSWorkspace.shared.icon(for:),
    open: NSWorkspace.shared.open,
    frontmostApplication: { NSWorkspace.shared.frontmostApplication },
    frontmostApplicationObservation: { toStream(workspace: .shared, options: $0, keyPath: \.frontmostApplication) },
    runningApplications: { NSWorkspace.shared.runningApplications },
    runningApplicationsObservation: { toStream(workspace: .shared, options: $0, keyPath: \.runningApplications) },
    menuBarOwningApplication: { NSWorkspace.shared.menuBarOwningApplication },
    menuBarOwningApplicationObservation: { toStream(workspace: .shared, options: $0, keyPath: \.menuBarOwningApplication) },
    notifications: { NSWorkspace.shared.notificationCenter.notifications(named: $0, object: $1).eraseToStream() })

  public static let testValue = NSWorkspaceClient()

  // MARK: Private

  private static func toStream<Value>(
    workspace: NSWorkspace,
    options: NSKeyValueObservingOptions,
    keyPath: KeyPath<NSWorkspace, Value>) -> AsyncStream<KeyValueObservedChange<Value>>
  {
    let (stream, continuation) = AsyncStream.makeStream(of: KeyValueObservedChange<Value>.self)
    let observation = workspace.observe(keyPath, options: options) { _, change in
      continuation.yield(.init(change))
    }
    continuation.onTermination = { _ in
      observation.invalidate()
    }
    return stream
  }

}

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
