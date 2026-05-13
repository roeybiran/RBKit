import AppKit
import Dependencies
import DependenciesTestSupport
import Testing

@testable import RBKit

@MainActor
struct AppWatcherClientTests {
  @Test(
    .dependencies {
      $0.processesClient = .nonXPC
      $0.sysctlClient = .nonZombie
    }
  )
  func `liveValue: should create valid client`() async {
    nonisolated(unsafe) var eventCount = 0

    let client = AppWatcherClient.liveValue

    var events1 = [AppWatcherEvent]()
    Task {
      for await evt in client.events() {
        events1.append(evt)
        eventCount += 1
        break
      }
    }

    var events2 = [AppWatcherEvent]()
    Task {
      for await evt in client.events() {
        events2.append(evt)
        eventCount += 1
        break
      }
    }

    try? await Task.sleep(for: .seconds(0.5))

    #expect(eventCount == 2)
  }
}
