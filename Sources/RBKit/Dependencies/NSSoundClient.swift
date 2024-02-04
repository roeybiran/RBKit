import AppKit.NSSound

import Dependencies
import DependenciesMacros

// MARK: - BeepClient

@DependencyClient
public struct NSSoundClient {
  public var beep: () -> Void
}

// MARK: DependencyKey

extension NSSoundClient: DependencyKey {
  public static let liveValue = NSSoundClient(beep: NSSound.beep)
  public static let testValue = NSSoundClient()
}

extension DependencyValues {
  public var beepClient: NSSoundClient {
    get { self[NSSoundClient.self] }
    set { self[NSSoundClient.self] = newValue }
  }
}
