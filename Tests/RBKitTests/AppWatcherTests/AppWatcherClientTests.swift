import AppKit
import Dependencies
import DependenciesTestSupport
import Testing

@testable import RBKit

@MainActor
struct AppWatcherClientTests {
  @Test(
    .disabled("Live NSWorkspace observation can hang in headless test environments"),
    .timeLimit(.minutes(1)),
    .dependencies {
      $0.processesClient = .nonXPC
      $0.sysctlClient = .nonZombie
    },
  )
  func `liveValue: should create valid client`() async {
    let client = AppWatcherClient.liveValue

    let event1Task = Task { @MainActor in
      var iterator = client.events().makeAsyncIterator()
      return await iterator.next()
    }

    let event2Task = Task { @MainActor in
      var iterator = client.events().makeAsyncIterator()
      return await iterator.next()
    }

    let events = await [event1Task.value, event2Task.value]
    #expect(events.allSatisfy { $0 != nil })
  }
}
