import AppKit

extension NSView {
  public static var supplementaryViewKind: String {
    userInterfaceIdentifier.rawValue
  }

  public func enumerateSubviews(using handler: (NSView) -> Void) {
    for subview in subviews {
      handler(subview)
      subview.enumerateSubviews(using: handler)
    }
  }

  /// https://stackoverflow.com/questions/41386423/get-image-from-calayer-or-nsview-swift-3
  public func image() -> NSImage? {
    let imageRep = bitmapImageRepForCachingDisplay(in: bounds)
    if let imageRep {
      cacheDisplay(in: bounds, to: imageRep)
      let data = imageRep.representation(using: .jpeg, properties: [:])
      if let data {
        return NSImage(data: data)
      } else {
        return nil
      }
    } else {
      return nil
    }
  }

}
