import AppKit
import Dependencies
import Testing

@testable import RBKit

@Suite
@MainActor
struct `AppWatcherClient Tests` {
  @Test
  func `liveValue: should create valid client`() async throws {
    nonisolated(unsafe) var eventCount = 0
    
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
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
    }
    
    #expect(eventCount == 2)
  }

}
