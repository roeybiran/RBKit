import Foundation
import Testing

@testable import RBKit

@Suite
struct `Key Value Stream Tests` {
    @Test
    func `Stream emits key path changes`() async throws {
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
