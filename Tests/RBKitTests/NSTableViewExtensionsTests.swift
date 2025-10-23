import AppKit
import Testing

@testable import RBKit

@MainActor
@Suite
struct `NSTableView Tests` {
    @Test
    func `makeView ofType:, should use type name as identifier`() async throws {
        let tableView = NSTableView()

        final class FooView: NSView {}

        let view = tableView.makeView(ofType: FooView.self)

        #expect(view.identifier == .init("FooView"))
    }
}
