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
}

@MainActor
func makeTestPane(_ label: String, identifier: String) -> Pane {
  Pane(label, identifier: identifier, systemImage: "gearshape") {
    Form { Text(label) }
  }
}
