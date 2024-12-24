import Testing

@testable import RBKit

struct RangeReplaceableCollectionExtensionsTests {
  @Test
  func test_append() {
    var sut = ["a"]
    sut.append("b", "c")
    #expect(sut == ["a", "b", "c"])
  }
}
