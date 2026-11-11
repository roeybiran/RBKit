import Dependencies
import Testing
@testable import RBAnalytics

@MainActor
struct AnalyticsServiceTests {
  @Test
  func `isEnabled, should read inverse disabled default`() {
    withDependencies {
      $0.userDefaultsClient.bool = { key in
        #expect(key == "analyticsDisabled")
        return false
      }
    } operation: {
      let service = AnalyticsService()

      #expect(service.isEnabled)
    }
  }

  @Test
  func `isEnabled setter, should write inverse disabled default`() async {
    await confirmation { setBoolCalled in
      withDependencies {
        $0.userDefaultsClient.setBool = { value, key in
          #expect(value)
          #expect(key == "analyticsDisabled")
          setBoolCalled()
        }
      } operation: {
        let service = AnalyticsService()

        service.isEnabled = false
      }
    }
  }

  @Test
  func `start, should initialize telemetry deck with current disabled state`() async {
    await confirmation { initialized in
      nonisolated(unsafe) var calls = [String]()

      withDependencies {
        $0.userDefaultsClient.bool = { key in
          #expect(key == "analyticsDisabled")
          return true
        }
        $0.telemetryDeckClient.terminate = {
          calls.append("terminate")
        }
        $0.telemetryDeckClient.initialize = { config in
          #expect(config.analyticsDisabled)
          calls.append("initialize")
          initialized()
        }
      } operation: {
        let service = AnalyticsService(appID: "telemetry-app")

        service.start()

        #expect(calls == ["terminate", "initialize"])
      }
    }
  }

  @Test
  func `signal, should map appActivated event`() async {
    await confirmation { signaled in
      withDependencies {
        $0.telemetryDeckClient.signal = { name in
          #expect(name == "appActivated")
          signaled()
        }
      } operation: {
        let service = AnalyticsService()

        service.signal(.appActivated)
      }
    }
  }

  @Test
  func `signal, should map custom event`() async {
    await confirmation { signaled in
      withDependencies {
        $0.telemetryDeckClient.signal = { name in
          #expect(name == "customEvent")
          signaled()
        }
      } operation: {
        let service = AnalyticsService()

        service.signal(.custom("customEvent"))
      }
    }
  }
}
