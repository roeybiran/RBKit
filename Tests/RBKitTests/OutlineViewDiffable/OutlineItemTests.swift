import CustomDump
import Testing

@testable import RBKit

struct `OutlineItem Tests` {

  // MARK: Internal

  @Test
  func `init(_:children:) should set value and children`() {
    let child = TestValue(id: 1, title: "Child")
    let root = TestValue(id: 0, title: "Root")

    let item = OutlineItem(
      root,
      children: [
        OutlineItem(child)
      ],
    )

    #expect(item.value == root)
    #expect(item.children.map(\.value) == [child])
  }

  @Test
  func `dynamicMemberLookup should forward value members`() {
    let item = OutlineItem(TestValue(id: 123, title: "Node"))

    #expect(item.id == 123)
    #expect(item.title == "Node")
  }

  @Test
  func `id should forward value id`() {
    #expect(OutlineItem(TestValue(id: 123, title: "Node")).id == 123)
  }

  @Test
  func `subscript(_:) should return child`() {
    let item = OutlineItem(
      TestValue(id: 0, title: "Root"),
      children: [
        OutlineItem(TestValue(id: 1, title: "First")),
        OutlineItem(TestValue(id: 2, title: "Second")),
      ],
    )

    expectNoDifference(item[1], OutlineItem(TestValue(id: 2, title: "Second")))
  }

  @Test
  func `== should compare ids`() {
    let lhs = OutlineItem(TestValue(id: 1, title: "Old"))
    let rhs = OutlineItem(
      TestValue(id: 1, title: "New"),
      children: [
        OutlineItem(TestValue(id: 2, title: "Child"))
      ],
    )

    #expect(lhs == rhs)
    #expect(Set([lhs, rhs]).count == 1)
  }

  // MARK: Private

  private struct TestValue: Equatable, Hashable, Identifiable {
    var id: Int
    var title: String
  }
}
