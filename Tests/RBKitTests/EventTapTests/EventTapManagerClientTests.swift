import Carbon
import Dependencies
import Testing
@testable import RBKit

@MainActor
struct EventTapManagerClientGlueCodeTests {
  @Test
  func `Can access live value and call getIsEnabled`() {
    let eventTapClient = EventTapManagerClient.liveValue
    let result = eventTapClient.getIsEnabled("non-existent-tap")
    #expect(result == false)
  }
}
