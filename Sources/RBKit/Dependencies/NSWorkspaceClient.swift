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
      let publisher = NSWorkspace.shared.publisher(for: \.menuBarOwningApplication)
      return AsyncStream(publisher.values) // doesn't work!
      if #available(macOS 999.0, *) {
      } else {
        return AsyncStream { continuation in
          let cancellable = publisher
            .sink { app in
              continuation.yield(app)
            }
          continuation.onTermination = { _ in
            cancellable.cancel()
          }
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
