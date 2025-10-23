import AppKit
import Testing

@testable import RBKit

@Suite
struct `NSDirectionalEdgeInsets Tests` {
    @Test
    func `init, with uniform value, should set all edges`() async throws {
        let insets = NSDirectionalEdgeInsets(2)

        #expect(insets.top == 2)
        #expect(insets.leading == 2)
        #expect(insets.bottom == 2)
        #expect(insets.trailing == 2)
    }

    @Test
    func `init, with top value, should default remaining edges to zero`() async throws {
        let insets = NSDirectionalEdgeInsets(top: 1)

        #expect(insets.top == 1)
        #expect(insets.leading == 0)
        #expect(insets.bottom == 0)
        #expect(insets.trailing == 0)
    }
}
