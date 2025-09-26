import AppKit
import Testing

@testable import RBKit

@Suite
struct `NSDirectionalEdgeInsets Extensions Tests` {
    @Test
    func `Init with uniform value sets all edges`() {
        let insets = NSDirectionalEdgeInsets(2)

        #expect(insets.top == 2)
        #expect(insets.bottom == 2)
        #expect(insets.leading == 2)
        #expect(insets.trailing == 2)
    }

    @Test
    func `Init with top value defaults remaining edges`() {
        let insets = NSDirectionalEdgeInsets(top: 1)

        #expect(insets.top == 1)
        #expect(insets.bottom == 0)
        #expect(insets.leading == 0)
        #expect(insets.trailing == 0)
    }
}
