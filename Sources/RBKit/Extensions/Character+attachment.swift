import AppKit.NSTextAttachment

extension Character {
  public static let attachment: Self = {
    if let character = Unicode.Scalar(NSTextAttachment.character) {
      return Self(character)
    } else {
      return Self("⍰")
    }
  }()
}
