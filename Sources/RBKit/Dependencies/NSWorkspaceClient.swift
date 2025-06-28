import AppKit.NSWorkspace
import Dependencies
import DependenciesMacros
import UniformTypeIdentifiers

// MARK: - NSWorkspaceClient

// https://www.donnywals.com/building-an-asyncsequence-with-asyncstream-makestream/
// https://gist.github.com/ole/fc5c1f4c763d28d9ba70940512e81916

@DependencyClient
public struct NSWorkspaceClient: Sendable {
  public var open: @Sendable (_ url: URL) -> Bool = { _ in false }
  public var activateFileViewerSelecting: @Sendable (_ fileURLs: [URL]) -> Void
  public var urlForApplication: @Sendable (_ withBundleIdentifier: String) -> URL?
  public var iconForFile: @Sendable (_ fullPath: String) -> NSImage = { _ in .init() }
  public var iconFor: @Sendable (_ contentType: UTType) -> NSImage = { _ in .init() }
  public var frontmostApplication: @Sendable () -> NSRunningApplication? = { nil }
  public var runningApplications: @Sendable () -> [NSRunningApplication] = { [] }
  public var runningApplicationsObservation: @Sendable (
    _ keyPath: KeyPath<NSWorkspace, [NSRunningApplication]>,
    _ options: NSKeyValueObservingOptions,
    _ changeHandler: @escaping (NSWorkspace, NSKeyValueObservedChange<[NSRunningApplication]>) -> Void) -> NSKeyValueObservation = { _, _, _ in NSObject().observe(\.hash, changeHandler: { _, _ in }) }
  public var menuBarOwningApplication: @Sendable () -> NSRunningApplication?
  @DependencyEndpoint(method: "menuBarOwningApplication")
  public var menuBarOwningApplicationObservation:
    @Sendable (_ options: NSKeyValueObservingOptions)
    -> AsyncStream<KeyValueObservedChange<NSRunningApplication?>> = { _ in .finished }
  public var accessibilityDisplayShouldReduceMotion: @Sendable () -> Bool = { false }
  public var notifications:
    @Sendable (_ named: Notification.Name, _ object: (any AnyObject & Sendable)?) -> AsyncStream<
      Notification
    > = { _, _ in
      .finished
    }
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {

  public static let liveValue = Self(
    open: { NSWorkspace.shared.open($0) },

    activateFileViewerSelecting: { NSWorkspace.shared.activateFileViewerSelecting($0) },

    urlForApplication: { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) },

    iconForFile: { NSWorkspace.shared.icon(forFile: $0) },

    iconFor: { NSWorkspace.shared.icon(for: $0) },

    frontmostApplication: { NSWorkspace.shared.frontmostApplication },

    runningApplications: { NSWorkspace.shared.runningApplications },

    runningApplicationsObservation: NSWorkspace.shared.observe,

    menuBarOwningApplication: { NSWorkspace.shared.menuBarOwningApplication },

    menuBarOwningApplicationObservation: {
      UncheckedSendable(
        keyValueStream(
          observed: NSWorkspace.shared,
          keyPath: \.menuBarOwningApplication,
          options: $0).map(\.change)).eraseToStream()
    },

    accessibilityDisplayShouldReduceMotion: {
      NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    },

    notifications: {
      NSWorkspace.shared.notificationCenter.notifications(named: $0, object: $1).eraseToStream()
    })

  public static let testValue = NSWorkspaceClient()
}

extension NSWorkspaceClient {
  public func runningApplicationsStream(options: NSKeyValueObservingOptions = [.initial, .new]) -> AsyncStream<KeyValueObservedChange<[NSRunningApplication]>> {
    let (stream, continuation) = AsyncStream.makeStream(of: KeyValueObservedChange<[NSRunningApplication]>.self)
    let observation = runningApplicationsObservation(\.runningApplications, options) { object, change in
      continuation.yield(KeyValueObservedChange(change))
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
