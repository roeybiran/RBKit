import Dependencies
import Testing
@testable import RBAnalytics

@MainActor
struct AnalyticsCheckboxViewModelTests {
  @Test
  func `init, should read enabled state from analytics service`() {
    withDependencies {
      $0.userDefaultsClient.bool = { _ in false }
    } operation: {
      let viewModel = AnalyticsCheckboxViewModel(appID: "telemetry-app")

      #expect(viewModel.isEnabled)
    }
  }

  @Test
  func `checkboxClicked, should update enabled state and restart analytics service`() async {
    nonisolated(unsafe) var analyticsDisabled = false

    await confirmation("default updated") { setBoolCalled in
      await confirmation("analytics initialized") { analyticsInitialized in
        withDependencies {
          $0.userDefaultsClient.bool = { _ in analyticsDisabled }
          $0.userDefaultsClient.setBool = { value, _ in
            #expect(value)
            analyticsDisabled = value
            setBoolCalled()
          }
          $0.telemetryDeckClient.initialize = { config in
            #expect(config.analyticsDisabled)
            analyticsInitialized()
          }
        } operation: {
          let viewModel = AnalyticsCheckboxViewModel(appID: "telemetry-app")

          viewModel.checkboxClicked(isOn: false)

          #expect(!viewModel.isEnabled)
        }
      }
    }
  }
}
