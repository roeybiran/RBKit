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
  public var open: @Sendable (_ url: URL) -> Bool = { _ in false }
  public var openItemURLs: @Sendable @MainActor (
    _ itemURLs: [URL],
    _ applicationURL: URL,
    _ configuration: NSWorkspace.OpenConfiguration
  ) async throws -> NSRunningApplication = { _, _, _ in
    throw CancellationError()
  }
  public var openURLWithConfiguration: @Sendable @MainActor (
    _ url: URL,
    _ configuration: NSWorkspace.OpenConfiguration
  ) async throws -> NSRunningApplication = { _, _ in
    throw CancellationError()
  }
  public var activateFileViewerSelecting: @Sendable (_ fileURLs: [URL]) -> Void
  public var urlForApplication: @Sendable (_ withBundleIdentifier: String) -> URL?
  public var iconForFile: @Sendable (_ fullPath: String) -> NSImage = { _ in .init() }
  public var iconForContentType: @Sendable (_ contentType: UTType) -> NSImage = { _ in .init() }
  public var frontmostApplication: @Sendable () -> NSRunningApplication? = { nil }
  public var runningApplications: @Sendable () -> [NSRunningApplication] = { [] }
  public var menuBarOwningApplication: @Sendable () -> NSRunningApplication?
  public var accessibilityDisplayShouldReduceMotion: @Sendable () -> Bool = { false }
  public var notifications: @Sendable (_ named: Notification.Name, _ object: (any AnyObject & Sendable)?) -> NotificationCenter
    .Notifications = { NotificationCenter().notifications(
      named: $0,
      object: $1,
    ) }

  @DependencyEndpoint(method: "observe")
  public var NSRunningApplicationArrayObservation: @Sendable (
    KeyPath<NSWorkspace, [NSRunningApplication]>,
    _ options: NSKeyValueObservingOptions,
    _ changeHandler: @escaping @Sendable (NSWorkspace, NSKeyValueObservedChange<[NSRunningApplication]>) -> Void,
  ) -> NSKeyValueObservation = { _, _, _ in NSObject().observe(
    \.hash,
    changeHandler: { _, _ in },
  ) }

  @DependencyEndpoint(method: "observe")
  public var optionalNSRunningApplicationObservation: @Sendable (
    KeyPath<NSWorkspace, NSRunningApplication?>,
    _ options: NSKeyValueObservingOptions,
    _ changeHandler: @escaping @Sendable (NSWorkspace, NSKeyValueObservedChange<NSRunningApplication?>) -> Void,
  ) -> NSKeyValueObservation = { _, _, _ in NSObject().observe(
    \.hash,
    changeHandler: { _, _ in },
  ) }

  @MainActor
  public func open(
    itemURLs: [URL],
    withApplicationAt applicationURL: URL,
    configuration: NSWorkspace.OpenConfiguration = .init()
  ) async throws -> NSRunningApplication {
    try await openItemURLs(itemURLs, applicationURL, configuration)
  }

  @MainActor
  public func open(
    url: URL,
    configuration: NSWorkspace.OpenConfiguration = .init()
  ) async throws -> NSRunningApplication {
    try await openURLWithConfiguration(url, configuration)
  }
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {
  public static let liveValue = Self(
    open: { NSWorkspace.shared.open($0) },
    openItemURLs: { try await NSWorkspace.shared.open($0, withApplicationAt: $1, configuration: $2) },
    openURLWithConfiguration: { try await NSWorkspace.shared.open($0, configuration: $1) },
    activateFileViewerSelecting: { NSWorkspace.shared.activateFileViewerSelecting($0) },
    urlForApplication: { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) },
    iconForFile: { NSWorkspace.shared.icon(forFile: $0) },
    iconForContentType: { NSWorkspace.shared.icon(for: $0) },
    frontmostApplication: { NSWorkspace.shared.frontmostApplication },
    runningApplications: { NSWorkspace.shared.runningApplications },
    menuBarOwningApplication: { NSWorkspace.shared.menuBarOwningApplication },
    accessibilityDisplayShouldReduceMotion: { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion },
    notifications: { NSWorkspace.shared.notificationCenter.notifications(named: $0, object: $1) },
    NSRunningApplicationArrayObservation: { NSWorkspace.shared.observe($0, options: $1, changeHandler: $2) },
    optionalNSRunningApplicationObservation: { NSWorkspace.shared.observe($0, options: $1, changeHandler: $2) },
  )

  public static let testValue = NSWorkspaceClient()
}

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
