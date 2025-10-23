import AppKit
import Dependencies
import Foundation
import Testing

@testable import RBKit

@Suite
struct `CGWindowValue Tests` {
    @Test
    func `init, with complete dictionary, should create value`() async throws {
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
    func `init, with missing window number, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowNumber] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with missing store type, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowStoreType] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with missing layer, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowLayer] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with missing bounds, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with bounds missing X value, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = ["X": CGFloat()]

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with bounds missing Y value, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = ["Y": CGFloat()]

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with bounds missing width, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = ["Width": CGFloat()]

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with bounds missing height, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowBounds] = ["Height": CGFloat()]

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with missing sharing state, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowSharingState] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with missing alpha, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowAlpha] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with missing owner pid, should return nil`() async throws {
        var dictionary = makeWindowDictionary()
        dictionary[kCGWindowOwnerPID] = nil

        #expect(CGWindowValue(dictionary) == nil)
    }

    @Test
    func `init, with missing memory usage, should return nil`() async throws {
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
