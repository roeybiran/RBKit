import Testing
import AppKit
@testable import RBKit

@Test
func testAttachmentCharacter() {
    // Test that the attachment character is not empty
  guard let unicode = Unicode.Scalar(NSTextAttachment.character) else {
    Issue.record()
    return
  }
  #expect(Character.attachment == Character(unicode))
}
