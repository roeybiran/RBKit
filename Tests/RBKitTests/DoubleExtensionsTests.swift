import Dependencies
import Testing

@testable import RBKit

struct DoubleExtensionsTests {
  @Test
  func test() {
    let a = Double(360).radians
    #expect(a == 2 * .pi)
  }
}
