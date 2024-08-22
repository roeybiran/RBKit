import AppKit.NSWorkspace
import Dependencies
import DependenciesMacros
import UniformTypeIdentifiers

// MARK: - NSWorkspaceClient

// https://www.donnywals.com/building-an-asyncsequence-with-asyncstream-makestream/
// https://gist.github.com/ole/fc5c1f4c763d28d9ba70940512e81916

@DependencyClient
public struct NSWorkspaceClient {
  public var iconForFile: (_ fullPath: String) -> NSImage = { _ in .init() }

  public var iconFor: (_ contentType: UTType) -> NSImage = { _ in .init() }

  public var open: (_ url: URL) -> Bool = { _ in false }

  public var frontmostApplication: () -> NSRunningApplication? = { nil }

  public var runningApplications: () -> [NSRunningApplication] = { [] }

  public var menuBarOwningApplication: () -> NSRunningApplication?

  @DependencyEndpoint(method: "menuBarOwningApplication")
  public var menuBarOwningApplicationObservation: (_ options: NSKeyValueObservingOptions)
  -> AsyncStream<KeyValueObservedChange<NSRunningApplication?>> = { _ in .finished }

  public var notifications: (_ named: Notification.Name, _ object: AnyObject?) -> AsyncStream<Notification> = { _, _ in
    .finished
  }
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    iconForFile: NSWorkspace.shared.icon(forFile:),
    iconFor: NSWorkspace.shared.icon(for:),
    open: NSWorkspace.shared.open,
    frontmostApplication: { NSWorkspace.shared.frontmostApplication },
    runningApplications: { NSWorkspace.shared.runningApplications },
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
