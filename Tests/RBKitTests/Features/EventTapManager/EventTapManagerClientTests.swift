import Carbon
import Dependencies
import Testing
@testable import RBKit

@MainActor
struct EventTapManagerClientGlueCodeTests {
  @Test
  func `Can access live value`() {
    let eventTapClient = EventTapManagerClient.liveValue
    _ = eventTapClient
  }
}
