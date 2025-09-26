import AppKit
import Testing

@testable import RBKit

@MainActor
@Suite
struct `NSTableView Extensions Tests` {
    @Test
    func `Make view uses type name as identifier`() {
        let tableView = NSTableView()

        final class FooView: NSView {}

        let view = tableView.makeView(ofType: FooView.self)

        #expect(view.identifier == .init("FooView"))
    }
}
