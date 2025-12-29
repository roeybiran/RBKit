import Carbon
import Dependencies
import Testing
@testable import RBKit

@Suite("EventTapManagerClient glue code tests")
struct EventTapManagerClientTests {
  @Test("Can access live value and call getIsEnabled")
  func eventTapManagerClient_withLiveValue_shouldReturnFalseForNonExistentTap() async throws {
    let eventTapClient = EventTapManagerClient.liveValue
    let result = eventTapClient.getIsEnabled("non-existent-tap")
    #expect(result == false)
  }
}
