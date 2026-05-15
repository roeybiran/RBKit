import AppKit

extension Character {
  public static let attachment =
    if let character = Unicode.Scalar(NSTextAttachment.character) {
      Self(character)
    } else {
      Self("⍰")
    }
}
