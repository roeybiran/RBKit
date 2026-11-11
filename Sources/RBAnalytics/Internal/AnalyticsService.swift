import Dependencies
import TelemetryDeck

// MARK: - AnalyticsService

@MainActor
final class AnalyticsService {

  // MARK: Lifecycle

  init(appID: String = "") {
    self.appID = appID
  }

  // MARK: Internal

  var isEnabled: Bool {
    get {
      !userDefaultsClient.bool(forKey: .DEFAULTS_KEY_ANALYTICS_DISABLED)
    }
    set {
      userDefaultsClient.setBool(value: !newValue, forKey: .DEFAULTS_KEY_ANALYTICS_DISABLED)
    }
  }

  func start() {
    assert(!appID.isEmpty)
    let config = TelemetryDeck.Config(appID: appID)
    config.analyticsDisabled = !isEnabled
    telemetryDeckClient.terminate()
    telemetryDeckClient.initialize(config)
  }

  func signal(_ event: AnalyticsEvent) {
    switch event {
    case .appActivated:
      telemetryDeckClient.signal("appActivated")
    case .custom(let name):
      telemetryDeckClient.signal(name)
    }
  }

  // MARK: Private

  @Dependency(\.telemetryDeckClient) private var telemetryDeckClient
  @Dependency(\.userDefaultsClient) private var userDefaultsClient

  private let appID: String
}

extension String {
  fileprivate static let DEFAULTS_KEY_ANALYTICS_DISABLED = Self("analyticsDisabled")
}
