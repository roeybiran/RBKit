import Dependencies
import Testing
@testable import RBAnalytics

@MainActor
struct AnalyticsServiceClientTests {
  @Test
  func `start, should start analytics service`() async {
    await confirmation { initialized in
      withDependencies {
        $0.userDefaultsClient.bool = { _ in false }
        $0.telemetryDeckClient.initialize = { config in
          #expect(!config.analyticsDisabled)
          initialized()
        }
      } operation: {
        AnalyticsServiceClient.liveValue.start("telemetry-app")
      }
    }
  }

  @Test
  func `getIsEnabled, should read analytics service state`() {
    withDependencies {
      $0.userDefaultsClient.bool = { _ in false }
    } operation: {
      #expect(AnalyticsServiceClient.liveValue.getIsEnabled())
    }
  }

  @Test
  func `setIsEnabled, with false, should disable analytics service`() async {
    await confirmation { setBoolCalled in
      withDependencies {
        $0.userDefaultsClient.setBool = { value, key in
          #expect(value)
          #expect(key == "analyticsDisabled")
          setBoolCalled()
        }
      } operation: {
        AnalyticsServiceClient.liveValue.setIsEnabled(false)
      }
    }
  }

  @Test
  func `setIsEnabled, with true, should enable analytics service`() async {
    await confirmation { setBoolCalled in
      withDependencies {
        $0.userDefaultsClient.setBool = { value, key in
          #expect(!value)
          #expect(key == "analyticsDisabled")
          setBoolCalled()
        }
      } operation: {
        AnalyticsServiceClient.liveValue.setIsEnabled(true)
      }
    }
  }

  @Test
  func `signal, should forward events to analytics service`() async {
    await confirmation { signaled in
      withDependencies {
        $0.telemetryDeckClient.signal = { name in
          #expect(name == "customEvent")
          signaled()
        }
      } operation: {
        AnalyticsServiceClient.liveValue.signal(.custom("customEvent"))
      }
    }
  }
}
