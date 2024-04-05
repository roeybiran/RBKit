import AppKit

extension NSTableView.AnimationOptions: CustomDebugStringConvertible {
  public var debugDescription: String {
    [
      (Self.effectFade, "effectFade"),
      (.effectGap, "effectGap"),
      (.slideUp, "slideUp"),
      (.slideDown, "slideDown"),
      (.slideLeft, "slideLeft"),
      (.slideRight, "slideRight"),
    ]
    .filter { contains($0.0) }
    .map(\.1)
    .joined(separator: ", ")
    .replaceEmpty(with: "<NONE>")
  }
}
