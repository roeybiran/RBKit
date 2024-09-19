import AppKit.NSSound

import Dependencies
import DependenciesMacros

// MARK: - NSSoundClient

@DependencyClient
public struct SoundClient: Sendable {
  public var beep: @Sendable () -> Void
}

// MARK: DependencyKey

extension SoundClient: DependencyKey {
  public static let liveValue = SoundClient(
    beep: { NSSound.beep() }
  )
  public static let testValue = SoundClient()
}

extension DependencyValues {
  public var soundClient: SoundClient {
    get { self[SoundClient.self] }
    set { self[SoundClient.self] = newValue }
  }
}
