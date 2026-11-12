import AppKit
import SwiftUI
import Testing
@testable import RBKit

// MARK: - PaneTests

@MainActor
struct PaneTests {
  @Test
  func `Pane.init(_:identifier:systemImage:content:), should store values and host the content`() {
    let pane = Pane("Test Pane", identifier: "test-pane", systemImage: "gearshape") {
      Form { Text("Hello") }
    }

    #expect(pane.label == "Test Pane")
    #expect(pane.identifier == "test-pane")
    #expect(pane.systemImage == "gearshape")
    #expect(pane.viewController is NSHostingController<AnyView>)
    #expect((pane.viewController as? NSHostingController<AnyView>)?.sizingOptions == [])
  }
}

@MainActor
func makeTestPane(_ label: String, identifier: String) -> Pane {
  Pane(label, identifier: identifier, systemImage: "gearshape") {
    Form { Text(label) }
  }
}
