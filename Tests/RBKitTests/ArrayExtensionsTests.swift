import Carbon
import CustomDump
import Testing

@testable import RBKit

struct ArrayExtensionsTests {
  @Test func test_concat() {
    let a = ["a"].concat(["b"])
    #expect(a == ["a", "b"])

    let b = ["a"].concat("b")
    #expect(b == ["a", "b"])
  }

  @Test func test_subscript_safe_get() {
    var a = ["a", "b", "c"]

    #expect(a[safe: 3] == nil)
    #expect(a[safe: 0] == "a")
    a[safe: 0] = "z"
    #expect(a[safe: 0] == "z")
    a[safe: 9] = "y"
    #expect(a[safe: 9] == nil)
  }
}
