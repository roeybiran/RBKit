import AppKit
import Testing

@testable import RBKit

@Suite
struct `Character Extensions Tests` {
    @Test
    func `Attachment character matches AppKit`() throws {
        let unicode = try #require(Unicode.Scalar(NSTextAttachment.character))

        #expect(Character.attachment == Character(unicode))
    }
}
