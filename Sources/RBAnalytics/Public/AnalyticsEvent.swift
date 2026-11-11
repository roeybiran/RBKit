// MARK: - AnalyticsEvent

public enum AnalyticsEvent: Sendable, Equatable {
  case appActivated
  case custom(String)
}
