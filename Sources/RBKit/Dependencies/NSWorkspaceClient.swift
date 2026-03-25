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
  public var openURLWithConfiguration: @Sendable @MainActor (
    _ url: URL,
    _ configuration: NSWorkspace.OpenConfiguration
  ) async throws -> NSRunningApplication = { _, _ in
    throw CancellationError()
  }

  @DependencyEndpoint(method: "open")
  public var openURLsWithApplicationAt: @Sendable @MainActor (
    _ itemURLs: [URL],
    _ withApplicationAt: URL,
    _ configuration: NSWorkspace.OpenConfiguration
  ) async throws -> NSRunningApplication = { _, _, _ in
    throw CancellationError()
  }

  public var open: @Sendable (_ url: URL) -> Bool = { _ in false }

  // MARK: - Launching and Hiding Apps

  public var openApplication: @Sendable @MainActor (
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
  @DependencyEndpoint(method: "frontmostApplication")
  public var frontmostApplicationChanges: @Sendable @MainActor (
    _ options: NSKeyValueObservingOptions
  ) -> AsyncStream<KeyValueObservedChange<NSRunningApplication?>> = { _ in
      .finished
  }

  public var runningApplications: @Sendable () -> [NSRunningApplication] = { [] }
  @DependencyEndpoint(method: "runningApplications")
  public var runningApplicationsChanges: @Sendable @MainActor (
    _ options: NSKeyValueObservingOptions
  ) -> AsyncStream<KeyValueObservedChange<[NSRunningApplication]>> = { _ in
      .finished
  }

  public var menuBarOwningApplication: @Sendable () -> NSRunningApplication?
  @DependencyEndpoint(method: "menuBarOwningApplication")
  public var menuBarOwningApplicationChanges: @Sendable @MainActor (
    _ options: NSKeyValueObservingOptions
  ) -> AsyncStream<KeyValueObservedChange<NSRunningApplication?>> = { _ in
      .finished
  }

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
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {
  private static let instance = NSWorkspace.shared

  public static let liveValue: Self = {
    Self(
      openURLWithConfiguration: { try await instance.open($0, configuration: $1) },
      openURLsWithApplicationAt: { try await instance.open($0, withApplicationAt: $1, configuration: $2) },
      open: { instance.open($0) },
      openApplication: { try await instance.openApplication(at: $0, configuration: $1) },
      activateFileViewerSelecting: { instance.activateFileViewerSelecting($0) },
      urlForApplication: { instance.urlForApplication(withBundleIdentifier: $0) },
      frontmostApplication: { instance.frontmostApplication },
      frontmostApplicationChanges: { options in
        keyValueChangeStream(
          observed: instance,
          keyPath: \.frontmostApplication,
          options: options,
        )
      },
      runningApplications: { instance.runningApplications },
      runningApplicationsChanges: { options in
        keyValueChangeStream(
          observed: instance,
          keyPath: \.runningApplications,
          options: options,
        )
      },
      menuBarOwningApplication: { instance.menuBarOwningApplication },
      menuBarOwningApplicationChanges: { options in
        keyValueChangeStream(
          observed: instance,
          keyPath: \.menuBarOwningApplication,
          options: options,
        )
      },
      iconForFile: { instance.icon(forFile: $0) },
      iconForContentType: { instance.icon(for: $0) },
      accessibilityDisplayShouldReduceMotion: { instance.accessibilityDisplayShouldReduceMotion },
      notifications: { instance.notificationCenter.notifications(named: $0, object: $1) },
    )
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
