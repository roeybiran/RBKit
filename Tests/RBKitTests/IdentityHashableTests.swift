import Testing

@testable import RBKit

struct IdentityHashableTests {
  @Test
  func `conformance, should use identity for equality and hashing`() {
    struct Identified: IdentityHashable {
      let value: Foo

      init(_ value: Foo) {
        self.value = value
      }
    }

    struct Foo: Identifiable {
      let id: String
      let name: String
    }

    let first = Identified(Foo(id: "a", name: "a"))
    let alsoFirst = Identified(Foo(id: "a", name: "a1"))
    let second = Identified(Foo(id: "b", name: "b"))

    #expect(first.name == "a")
    #expect(first == alsoFirst)
    #expect(first.hashValue == alsoFirst.hashValue)
    #expect(first.hashValue == first.id.hashValue)
    #expect(first != second)
  }
}
