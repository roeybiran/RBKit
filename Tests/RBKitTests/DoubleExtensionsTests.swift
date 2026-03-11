import Dependencies
import Testing

@testable import RBKit

struct DoubleTests {
  @Test
  func `radians, should convert degrees to radians`() {
    let radians = Double(360).radians

    #expect(radians == 2 * .pi)
  }
}
