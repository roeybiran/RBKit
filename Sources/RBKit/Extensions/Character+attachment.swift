import AppKit

extension Character {
  public static let attachment =
    if let character = Unicode.Scalar(NSAttachmentCharacter) {
      Self(character)
    } else {
      Self("⍰")
    }
}
