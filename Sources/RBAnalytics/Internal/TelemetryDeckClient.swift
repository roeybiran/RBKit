import Dependencies
import TelemetryDeck

// MARK: - TelemetryDeckClient

struct TelemetryDeckClient: Sendable {
  var terminate: @MainActor @Sendable () -> Void = { }
  var initialize: @MainActor @Sendable (TelemetryDeck.Config) -> Void = { _ in }
  var signal: @MainActor @Sendable (String) -> Void = { _ in }
}

// MARK: DependencyKey

extension TelemetryDeckClient: DependencyKey {
  static let liveValue = Self(
    terminate: {
      TelemetryDeck.terminate()
    },
    initialize: { config in
      TelemetryDeck.initialize(config: config)
    },
    signal: {
      TelemetryDeck.signal($0)
    },
  )

  static let testValue = Self()
}

extension DependencyValues {
  var telemetryDeckClient: TelemetryDeckClient {
    get { self[TelemetryDeckClient.self] }
    set { self[TelemetryDeckClient.self] = newValue }
  }
}
