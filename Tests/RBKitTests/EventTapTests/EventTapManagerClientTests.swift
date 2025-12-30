import Carbon
import Dependencies
import Testing
@testable import RBKit

@MainActor
@Suite
struct `EventTapManagerClient glue code tests` {
  @Test
  func `Can access live value and call getIsEnabled`() async throws {
    let eventTapClient = EventTapManagerClient.liveValue
    let result = eventTapClient.getIsEnabled("non-existent-tap")
    #expect(result == false)
  }
}
