@preconcurrency import AppKit
import Dependencies
import DependenciesMacros

// MARK: - NSAlertClient

@DependencyClient
public struct NSAlertClient: Sendable {
  public var runModal: @Sendable @MainActor (_ alert: NSAlert) -> NSApplication.ModalResponse = { _ in .OK }
}

// MARK: DependencyKey

extension NSAlertClient: DependencyKey {
  public static let liveValue = Self(
    runModal: { $0.runModal() }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsAlertClient: NSAlertClient {
    get { self[NSAlertClient.self] }
    set { self[NSAlertClient.self] = newValue }
  }
}
