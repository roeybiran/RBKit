import AppKit

extension NSBox {
  public enum Axis {
    case vertical
    case horizontal
  }

  public static func separator(_ axis: Axis = .horizontal) -> NSBox {
    let box = NSBox(
      frame: NSRect(
        origin: .zero,
        size: axis == .horizontal
          ? .init(width: 96, height: 5)
          : .init(width: 5, height: 96)
      )
    )
    box.boxType = .separator
    return box
  }
}
