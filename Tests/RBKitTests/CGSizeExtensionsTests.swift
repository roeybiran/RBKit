import Foundation
import Testing

@testable import RBKit

@Suite
struct `CGSize Clamp Tests` {
    @Test
    func `Clamp keeps smaller sizes`() {
        let original = CGSize(width: 100, height: 50)
        let maximum = CGSize(width: 200, height: 100)

        let clamped = original.clamp(to: maximum)

        #expect(clamped.width == 100)
        #expect(clamped.height == 50)
    }

    @Test
    func `Clamp trims oversized dimensions`() {
        let original = CGSize(width: 400, height: 300)
        let maximum = CGSize(width: 200, height: 150)

        let clamped = original.clamp(to: maximum)

        #expect(clamped.width == 200)
        #expect(clamped.height == 150)
    }

    @Test
    func `Clamp preserves aspect ratio`() {
        let original = CGSize(width: 400, height: 200)
        let maximum = CGSize(width: 200, height: 200)

        let clamped = original.clamp(to: maximum)

        #expect(clamped.width == 200)
        #expect(clamped.height == 100)
    }

    @Test
    func `Clamp leaves zero dimensions unchanged`() {
        let original = CGSize(width: 0, height: 0)
        let maximum = CGSize(width: 200, height: 200)

        let clamped = original.clamp(to: maximum)

        #expect(clamped.width == 0)
        #expect(clamped.height == 0)
    }

    @Test
    func `Clamp leaves negative dimensions unchanged`() {
        let original = CGSize(width: -100, height: -50)
        let maximum = CGSize(width: 200, height: 200)

        let clamped = original.clamp(to: maximum)

        #expect(clamped.width == -100)
        #expect(clamped.height == -50)
    }
}
