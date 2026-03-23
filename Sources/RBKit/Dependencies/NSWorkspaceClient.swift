@preconcurrency
import AppKit.NSWorkspace
import Dependencies
import DependenciesMacros
import UniformTypeIdentifiers

// MARK: - NSWorkspaceClient

// https://www.donnywals.com/building-an-asyncsequence-with-asyncstream-makestream/
// https://gist.github.com/ole/fc5c1f4c763d28d9ba70940512e81916

@DependencyClient
public struct NSWorkspaceClient: Sendable {
  // MARK: - Opening URLs

  @DependencyEndpoint(method: "open")
  public var openWithConfiguration: @Sendable @MainActor (
    _ url: URL,
    _ configuration: NSWorkspace.OpenConfiguration
  ) async throws -> NSRunningApplication = { _, _ in
    throw CancellationError()
  }

  @DependencyEndpoint(method: "open")
  public var openWithApplicationAt: @Sendable @MainActor (
    _ itemURLs: [URL],
    _ withApplicationAt: URL,
    _ configuration: NSWorkspace.OpenConfiguration
  ) async throws -> NSRunningApplication = { _, _, _ in
    throw CancellationError()
  }

  public var open: @Sendable (_ url: URL) -> Bool = { _ in false }

  // MARK: - Launching and Hiding Apps

  @DependencyEndpoint(method: "openApplication")
  public var openApplicationAt: @Sendable @MainActor (
    _ at: URL,
    _ configuration: NSWorkspace.OpenConfiguration
  ) async throws -> NSRunningApplication = { _, _ in
    throw CancellationError()
  }

  // MARK: - Manipulating Files

  public var activateFileViewerSelecting: @Sendable (_ fileURLs: [URL]) -> Void

  // MARK: - Requesting Information

  public var urlForApplication: @Sendable (_ withBundleIdentifier: String) -> URL?
  public var frontmostApplication: @Sendable () -> NSRunningApplication? = { nil }
  public var runningApplications: @Sendable () -> [NSRunningApplication] = { [] }
  public var menuBarOwningApplication: @Sendable () -> NSRunningApplication?

  // MARK: - Managing Icons

  @DependencyEndpoint(method: "icon")
  public var iconForFile: @Sendable (_ forFile: String) -> NSImage = { _ in .init() }
  @DependencyEndpoint(method: "icon")
  public var iconForContentType: @Sendable (_ `for`: UTType) -> NSImage = { _ in .init() }

  // MARK: - Supporting Accessibility

  public var accessibilityDisplayShouldReduceMotion: @Sendable () -> Bool = { false }

  // MARK: - Accessing the Workspace Notification Center

  public var notifications: @Sendable (_ named: Notification.Name, _ object: (any AnyObject & Sendable)?) -> NotificationCenter
    .Notifications = { NotificationCenter().notifications(
      named: $0,
      object: $1,
    ) }

  // MARK: - Custom

  @DependencyEndpoint(method: "changes")
  public var runningApplicationsChanges: @Sendable @MainActor (
    _ options: NSKeyValueObservingOptions
  ) -> AsyncStream<KeyValueObservedChange<[NSRunningApplication]>> = { _ in
    .finished
  }

  @DependencyEndpoint(method: "changes")
  public var frontmostApplicationChanges: @Sendable @MainActor (
    _ options: NSKeyValueObservingOptions
  ) -> AsyncStream<KeyValueObservedChange<NSRunningApplication?>> = { _ in
    .finished
  }

  @DependencyEndpoint(method: "observeMenuBarOwningApplication")
  public var menuBarOwningApplicationChanges: @Sendable @MainActor (
    _ options: NSKeyValueObservingOptions
  ) -> AsyncStream<KeyValueObservedChange<NSRunningApplication?>> = { _ in
    .finished
  }
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {
  private static let instance = NSWorkspace.shared

  public static var liveValue: Self {
    Self(
      openWithConfiguration: { try await instance.open($0, configuration: $1) },
      openWithApplicationAt: { try await instance.open($0, withApplicationAt: $1, configuration: $2) },
      open: { instance.open($0) },
      openApplicationAt: { try await instance.openApplication(at: $0, configuration: $1) },
      activateFileViewerSelecting: { instance.activateFileViewerSelecting($0) },
      urlForApplication: { instance.urlForApplication(withBundleIdentifier: $0) },
      frontmostApplication: { instance.frontmostApplication },
      runningApplications: { instance.runningApplications },
      menuBarOwningApplication: { instance.menuBarOwningApplication },
      iconForFile: { instance.icon(forFile: $0) },
      iconForContentType: { instance.icon(for: $0) },
      accessibilityDisplayShouldReduceMotion: { instance.accessibilityDisplayShouldReduceMotion },
      notifications: { instance.notificationCenter.notifications(named: $0, object: $1) },
      runningApplicationsChanges: { options in
        keyValueChangeStream(
          observed: instance,
          keyPath: \.runningApplications,
          options: options,
        )
      },
      frontmostApplicationChanges: { options in
        keyValueChangeStream(
          observed: instance,
          keyPath: \.frontmostApplication,
          options: options,
        )
      },
      menuBarOwningApplicationChanges: { options in
        keyValueChangeStream(
          observed: instance,
          keyPath: \.menuBarOwningApplication,
          options: options,
        )
      },
    )
  }

  public static var testValue: Self {
    Self()
  }
}

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
