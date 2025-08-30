import AppKit
import Testing
@testable import RBKit

@Test
func attachmentCharacter() throws {
  // Test that the attachment character is not empty
  let unicode = try #require(Unicode.Scalar(NSTextAttachment.character))
  #expect(Character.attachment == Character(unicode))
}
