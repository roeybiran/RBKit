import AppKit.NSSound
import Dependencies
import DependenciesMacros

// MARK: - BeepClient

@DependencyClient
public struct BeepClient {
  public var beep: () -> Void
}

// MARK: DependencyKey

extension BeepClient: DependencyKey {
  public static let liveValue = BeepClient(beep: NSSound.beep)
  public static let testValue = BeepClient()
}

extension DependencyValues {
  public var beepClient: BeepClient {
    get { self[BeepClient.self] }
    set { self[BeepClient.self] = newValue }
  }
}
