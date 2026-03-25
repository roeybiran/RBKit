import AppKit
import Testing

@testable import RBKit

struct CharacterTests {
  @Test
  func `attachment, should match NSTextAttachment character`() throws {
    let unicode = try #require(Unicode.Scalar(NSAttachmentCharacter))

    #expect(Character.attachment == Character(unicode))
  }
}
