import AppKit
import Testing

@testable import RBKit

@MainActor
@Suite
struct `NSObject Extensions Tests` {
    @Test
    func `Dot syntax settable updates identifiers`() {
        let view = NSView()

        #expect(view.identifier == nil)

        view.set(\.identifier, to: .init("foo"))

        #expect(view.identifier == .init("foo"))
    }
}
