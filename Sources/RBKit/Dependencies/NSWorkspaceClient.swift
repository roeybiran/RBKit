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

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
