import AppKit
import Dependencies
import DependenciesTestSupport
import Testing

@testable import RBKit

@MainActor
struct AppWatcherClientTests {
  @Test(
    .timeLimit(.minutes(1)),
    .dependencies {
      $0.nsWorkspaceClient = .liveValue
      $0.nsRunningApplicationClient = .liveValue
      $0.processesClient = .nonXPC
      $0.sysctlClient = .nonZombie
    },
  )
  func `liveValue: should create valid client`() async {
    let client = AppWatcherClient.liveValue

    // Each stream emits an initial `.launched` event. Wait for it rather than sleeping a fixed
    // interval, which is flaky on loaded CI runners.
    let first1 = Task { await client.events().first { _ in true } }
    let first2 = Task { await client.events().first { _ in true } }

    let (event1, event2) = await (first1.value, first2.value)

    #expect(event1 != nil)
    #expect(event2 != nil)
  }
}
