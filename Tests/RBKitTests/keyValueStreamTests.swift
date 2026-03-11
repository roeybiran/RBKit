import Foundation
import Testing

@testable import RBKit

struct KeyValueStreamTests {
  @Test
  func `keyValueStream, with keyPath, should emit changes`() async {
    await confirmation { confirm in
      class ObservedObject: NSObject {
        @objc dynamic var name = ""
      }

      let object = ObservedObject()

      Task {
        for await (instance, change) in keyValueStream(observed: object, keyPath: \.name) {
          #expect(instance === object)
          #expect(change.newValue == "john")
          confirm()
        }
      }

      object.name = "john"

      try? await Task.sleep(for: .seconds(0.05))
    }
  }
}
