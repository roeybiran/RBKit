import Foundation
import Testing

@testable import RBKit

@Suite
struct KeyValueStreamTests {
  @Test
  func initStream() async throws {
    await confirmation { c in
      class Obj: NSObject {
        @objc dynamic var name = ""
      }

      let sut = Obj()

      Task {
        for await (obj, change) in keyValueStream(observed: sut, keyPath: \.name) {
          #expect(obj === sut)
          #expect(change.newValue == "john")
          c()
        }
      }

      sut.name = "john"

      try? await Task.sleep(for: .seconds(0.05))
    }
  }
}
