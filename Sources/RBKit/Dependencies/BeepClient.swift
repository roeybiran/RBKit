import AppKit.NSSound
import Dependencies

// MARK: - BeepClient

public struct BeepClient {
  public var beep: () -> Void
}

// MARK: DependencyKey

extension BeepClient: DependencyKey {
  public static let liveValue = BeepClient(beep: NSSound.beep)

  #if DEBUG
  public static let testValue = BeepClient(beep: unimplemented("BeepClient.beep"))
  #endif
}

extension DependencyValues {
  public var beepClient: BeepClient {
    get { self[BeepClient.self] }
    set { self[BeepClient.self] = newValue }
  }
}
