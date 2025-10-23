import AppKit
import Testing

@testable import RBKit

@Suite
struct `Character Tests` {
    @Test
    func `attachment, should match NSTextAttachment character`() async throws {
        let unicode = try #require(Unicode.Scalar(NSTextAttachment.character))

        #expect(Character.attachment == Character(unicode))
    }
}
