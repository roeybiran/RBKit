import SwiftUI
import Testing
@testable import RBKit

// MARK: - PaneTests

@MainActor
struct PaneTests {
  @Test
  func `Pane.init(_:identifier:systemImage:content:), should store values`() {
    let pane = makeTestPane("Test Pane", identifier: "test-pane")

    #expect(pane.label == "Test Pane")
    #expect(pane.identifier == "test-pane")
    #expect(pane.systemImage == "gearshape")
  }

  @Test
  func `Pane.content, should be rebuilt each time it is shown`() {
    var buildCount = 0
    let pane = Pane("Test Pane", identifier: "test-pane", systemImage: "gearshape") {
      let _ = buildCount += 1
      Form { }
    }

    #expect(buildCount == 0)
    _ = pane.content()
    _ = pane.content()
    #expect(buildCount == 2)
  }
}

@MainActor
func makeTestPane(_ label: String, identifier: String) -> Pane {
  Pane(label, identifier: identifier, systemImage: "gearshape") {
    Form { Text(label) }
  }
}
