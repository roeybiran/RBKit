import AppKit

extension NSView {
  public func addSubviews(_ views: NSView...) {
    views.forEach { addSubview($0) }
  }

  public func enumerateSubviews(using handler: (NSView) -> Void) {
    subviews.forEach {
      handler($0)
      $0.enumerateSubviews(using: handler)
    }
  }

  // https://stackoverflow.com/questions/41386423/get-image-from-calayer-or-nsview-swift-3
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

  public static var supplementaryViewKind: String {
    userInterfaceIdentifier.rawValue
  }
}

