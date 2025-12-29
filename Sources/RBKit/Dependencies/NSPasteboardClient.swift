@preconcurrency import AppKit.NSPasteboard
import Dependencies
import DependenciesMacros

// MARK: - NSPasteboardClient

@DependencyClient
public struct NSPasteboardClient: Sendable {
  public var clearContents: @Sendable () -> Void
  public var setString: @Sendable (_ string: String, _ dataType: NSPasteboard.PasteboardType) -> Bool = { _, _ in false }
}

// MARK: DependencyKey

extension NSPasteboardClient: DependencyKey {
  public static let liveValue = Self(
    clearContents: { NSPasteboard.general.clearContents() },
    setString: { NSPasteboard.general.setString($0, forType: $1) },
  )

  public static let testValue = NSPasteboardClient()
}

extension DependencyValues {
  public var pasteboard: NSPasteboardClient {
    get { self[NSPasteboardClient.self] }
    set { self[NSPasteboardClient.self] = newValue }
  }
}
