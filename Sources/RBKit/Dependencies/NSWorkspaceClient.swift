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
  public var activateFileViewerSelecting: @Sendable (_ fileURLs: [URL]) -> Void
  public var urlForApplication: @Sendable (_ withBundleIdentifier: String) -> URL?
  public var iconForFile: @Sendable (_ fullPath: String) -> NSImage = { _ in .init() }
  public var iconForContentType: @Sendable (_ contentType: UTType) -> NSImage = { _ in .init() }
  public var frontmostApplication: @Sendable () -> NSRunningApplication? = { nil }
  public var runningApplications: @Sendable () -> [NSRunningApplication] = { [] }
  public var menuBarOwningApplication: @Sendable () -> NSRunningApplication?
  public var accessibilityDisplayShouldReduceMotion: @Sendable () -> Bool = { false }
  public var notifications: @Sendable (_ named: Notification.Name, _ object: (any AnyObject & Sendable)?) -> NotificationCenter.Notifications = { NotificationCenter().notifications(named: $0, object: $1) }

  @DependencyEndpoint(method: "observe")
  public var NSRunningApplicationArrayObservation: (
    KeyPath<NSWorkspace, [NSRunningApplication]>,
    _ options: NSKeyValueObservingOptions,
    _ changeHandler: @escaping (NSWorkspace, NSKeyValueObservedChange<[NSRunningApplication]>) -> Void) -> NSKeyValueObservation = { _, _, _ in NSObject().observe(\.hash, changeHandler: { _, _ in }) }

  @DependencyEndpoint(method: "observe")
  public var optionalNSRunningApplicationObservation: (
    KeyPath<NSWorkspace, NSRunningApplication?>,
    _ options: NSKeyValueObservingOptions,
    _ changeHandler: @escaping (NSWorkspace, NSKeyValueObservedChange<NSRunningApplication?>) -> Void) -> NSKeyValueObservation = { _, _, _ in NSObject().observe(\.hash, changeHandler: { _, _ in }) }
}

// MARK: DependencyKey

extension NSWorkspaceClient: DependencyKey {
  public static let liveValue = Self(
    open: NSWorkspace.shared.open,
    activateFileViewerSelecting: NSWorkspace.shared.activateFileViewerSelecting,
    urlForApplication: NSWorkspace.shared.urlForApplication,
    iconForFile: NSWorkspace.shared.icon(forFile:),
    iconForContentType: NSWorkspace.shared.icon,
    frontmostApplication: { NSWorkspace.shared.frontmostApplication },
    runningApplications: { NSWorkspace.shared.runningApplications },
    menuBarOwningApplication: { NSWorkspace.shared.menuBarOwningApplication },
    accessibilityDisplayShouldReduceMotion: { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion },
    notifications: NSWorkspace.shared.notificationCenter.notifications,
    NSRunningApplicationArrayObservation: NSWorkspace.shared.observe,
    optionalNSRunningApplicationObservation: NSWorkspace.shared.observe,
  )

  public static let testValue = NSWorkspaceClient()
}

extension DependencyValues {
  public var nsWorkspaceClient: NSWorkspaceClient {
    get { self[NSWorkspaceClient.self] }
    set { self[NSWorkspaceClient.self] = newValue }
  }
}
