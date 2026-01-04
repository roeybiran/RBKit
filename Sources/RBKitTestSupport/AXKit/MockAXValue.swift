import ApplicationServices
import Foundation

class MockAXValue: NSObject {
  let type: AXValueType

  init(type: AXValueType) {
    self.type = type
    super.init()
  }
}

