import AppKit.NSCursor
import Dependencies
import DependenciesMacros

// MARK: - NSCursorClient

@DependencyClient
public struct NSCursorClient: Sendable {
  public var hide: @Sendable @MainActor () -> Void
  public var unhide: @Sendable @MainActor () -> Void
}

// MARK: DependencyKey

extension NSCursorClient: DependencyKey {
  public static let liveValue = NSCursorClient(
    hide: { NSCursor.hide() },
    unhide: { NSCursor.unhide() },
  )
  public static let testValue = NSCursorClient()
}

extension DependencyValues {
  public var nsCursorClient: NSCursorClient {
    get { self[NSCursorClient.self] }
    set { self[NSCursorClient.self] = newValue }
  }
}
