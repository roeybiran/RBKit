import AppKit
import Dependencies
import Foundation
import Testing

@testable import RBKit

@Suite
struct `CG Window Tests` {
    @Test
    func `Init succeeds with complete dictionary`() {
        let dictionary = makeWindowDictionary()
        let value = CGWindowValue(dictionary)
        let expected = CGWindowValue(
            number: 0,
            storeType: 0,
            layer: 0,
            bounds: .zero,
            sharingState: 0,
            alpha: 0,
            ownerPID: 0,
            memoryUsage: 0,
            ownerName: nil,
            name: nil,
            isOnscreen: nil,
            backingLocationVideoMemory: nil
        )

        #expect(value == expected)
    }

    @Test
    func `Missing window number returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowNumber] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Missing store type returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowStoreType] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Missing layer returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowLayer] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Missing bounds returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Bounds missing X value returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = ["X": CGFloat()]

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Bounds missing Y value returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = ["Y": CGFloat()]

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Bounds missing width returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = ["Width": CGFloat()]

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Bounds missing height returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = ["Height": CGFloat()]

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Missing sharing state returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowSharingState] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Missing alpha returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowAlpha] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Missing owner pid returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowOwnerPID] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `Missing memory usage returns nil`() {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowMemoryUsage] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    private func makeWindowDictionary() -> [CFString: Any] {
        var dictionary = [CFString: Any]()
        dictionary[kCGWindowNumber] = CGWindowID()
        dictionary[kCGWindowStoreType] = 0
        dictionary[kCGWindowLayer] = Int32()
        dictionary[kCGWindowBounds] = [
            "X": 0.0,
            "Y": 0.0,
            "Width": 0.0,
            "Height": 0.0,
        ] as CFDictionary
        dictionary[kCGWindowSharingState] = 0
        dictionary[kCGWindowAlpha] = CGFloat()
        dictionary[kCGWindowOwnerPID] = pid_t()
        dictionary[kCGWindowMemoryUsage] = 0
        return dictionary
    }
}
