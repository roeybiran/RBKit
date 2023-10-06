import AppKit.NSWorkspace
import Dependencies

// MARK: - NSWorkspaceClient

public struct NSWorkspaceClient {
  public var iconForFile: (_ path: String) -> NSImage
  public var open: (_ url: URL) -> Bool
  public var menuBarOwningApplications: () -> AsyncStream<NSRunningApplication?>
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {
  public static let liveValue = NSWorkspaceClient(
    iconForFile: NSWorkspace.shared.icon(forFile:),
    open: NSWorkspace.shared.open,
    menuBarOwningApplications: {
      let publisher = NSWorkspace.shared.publisher(for: \.menuBarOwningApplication)
      if #available(macOS 999.0, *) {
        return AsyncStream(publisher.values) // doesn't work!
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
    })

  public static let testValue = NSWorkspaceClient(
    iconForFile: unimplemented("terminate"),
    open: unimplemented("open"),
    menuBarOwningApplications: unimplemented("menuBarOwningApplications"))
}

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
