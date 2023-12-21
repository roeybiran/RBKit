import AppKit.NSWorkspace
import Dependencies
import DependenciesMacros
import UniformTypeIdentifiers

// MARK: - NSWorkspaceClient

@DependencyClient
public struct NSWorkspaceClient {
  public var notificationCenter: () -> NotificationCenter = { .init() }
  public var iconForFile: (_ fullPath: String) -> NSImage = { _ in .init() }
  public var iconFor: (_ contentType: UTType) -> NSImage = { _ in .init() }
  public var open: (_ url: URL) -> Bool = { _ in false }
  public var frontmostApplication: () -> NSRunningApplication? = { nil }
  public var runningApplications: () -> [NSRunningApplication] = { [] }
  public var menuBarOwningApplication: () -> AsyncStream<NSRunningApplication?> = { .finished }
  
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {
  public static let liveValue = NSWorkspaceClient(
    notificationCenter: { NSWorkspace.shared.notificationCenter },
    iconForFile: NSWorkspace.shared.icon(forFile:),
    iconFor: NSWorkspace.shared.icon(for:),
    open: NSWorkspace.shared.open,
    frontmostApplication: { NSWorkspace.shared.frontmostApplication },
    runningApplications: { NSWorkspace.shared.runningApplications },
    menuBarOwningApplication: {
      // return AsyncStream(publisher.values) // doesn't work!
      return AsyncStream { continuation in
        let cancellable = NSWorkspace
          .shared
          .publisher(for: \.menuBarOwningApplication)
          .sink { app in
            continuation.yield(app)
          }
        continuation.onTermination = { _ in
          cancellable.cancel()
        }
      }
    }
  )

  public static let testValue = NSWorkspaceClient()
}

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
