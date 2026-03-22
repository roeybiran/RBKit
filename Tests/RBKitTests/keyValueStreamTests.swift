import Foundation
import Testing

@testable import RBKit

struct KeyValueStreamTests {
  @Test
  func `keyValueChangeStream, with keyPath, should map all change fields`() async {
    class ObservedObject: NSObject {
      @objc dynamic var name = ""
    }

    let object = ObservedObject()
    let stream = keyValueChangeStream(
      observed: object,
      keyPath: \.name,
      options: [.initial, .new, .old, .prior],
    )
    var iterator = stream.makeAsyncIterator()

    let initial = await iterator.next()
    #expect(initial?.kind == .setting)
    #expect(initial?.oldValue == nil)
    #expect(initial?.newValue == "")
    #expect(initial?.indexes == nil)
    #expect(initial?.isPrior == false)

    object.name = "john"

    let prior = await iterator.next()
    #expect(prior?.kind == .setting)
    #expect(prior?.oldValue == "")
    #expect(prior?.newValue == nil)
    #expect(prior?.indexes == nil)
    #expect(prior?.isPrior == true)

    let after = await iterator.next()
    #expect(after?.kind == .setting)
    #expect(after?.oldValue == "")
    #expect(after?.newValue == "john")
    #expect(after?.indexes == nil)
    #expect(after?.isPrior == false)
  }
}
