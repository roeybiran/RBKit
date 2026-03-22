import ApplicationServices
import Foundation

class MockAXValue: NSObject {

  // MARK: Lifecycle

  init(type: AXValueType) {
    self.type = type
    super.init()
  }

  // MARK: Internal

  let type: AXValueType

}
