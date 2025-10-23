import AppKit
import Testing

@testable import RBKit

@MainActor
@Suite
struct `NSObject Tests` {
    @Test
    func `set, with keyPath, should update value`() async throws {
        let view = NSView()

        #expect(view.identifier == nil)

        view.set(\.identifier, to: .init("foo"))

        #expect(view.identifier == .init("foo"))
    }
}
