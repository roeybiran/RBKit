import Dependencies
import Observation

@MainActor
@Observable
final class AnalyticsCheckboxViewModel {

  // MARK: Lifecycle

  init(appID: String) {
    analyticsService = AnalyticsService(appID: appID)
    isEnabled = analyticsService.isEnabled
  }

  // MARK: Internal

  private(set) var isEnabled = false

  func checkboxClicked(isOn: Bool) {
    isEnabled = isOn
    analyticsService.isEnabled = isOn
    analyticsService.start()
  }

  // MARK: Private

  @ObservationIgnored private let analyticsService: AnalyticsService
}
