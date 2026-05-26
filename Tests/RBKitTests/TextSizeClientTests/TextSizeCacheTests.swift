import AppKit
import Testing

@testable import RBKit

@Suite(.serialized)
struct TextSizeCacheTests {
  @MainActor
  @Test
  func sizeReturnsMeasuredSize() {
    let cache = TextSizeCache()
    let font = NSFont.systemFont(ofSize: 13)
    let key = TextSizeCache.Key(
      fontName: font.fontName,
      fontSize: font.pointSize,
      string: "Hello",
      boldCharacterCount: 0,
    )
    let expectedSize = NSAttributedString(
      string: "Hello",
      attributes: [.font: font],
    ).size()

    #expect(cache.size(for: key) == .init(
      width: ceil(expectedSize.width),
      height: ceil(expectedSize.height),
    ))
  }

  @MainActor
  @Test
  func sizeSeparatesDistinctKeys() {
    let cache = TextSizeCache()
    let font = NSFont.systemFont(ofSize: 13)

    let shortSize = cache.size(for: .init(
      fontName: font.fontName,
      fontSize: font.pointSize,
      string: "A",
      boldCharacterCount: 0,
    ))
    let longSize = cache.size(for: .init(
      fontName: font.fontName,
      fontSize: font.pointSize,
      string: "Alphabet",
      boldCharacterCount: 0,
    ))

    #expect(longSize.width > shortSize.width)
    #expect(longSize.height == shortSize.height)
  }

  @MainActor
  @Test
  func sizeReturnsCachedSizeForRepeatedKey() {
    let cache = TextSizeCache()
    let font = NSFont.systemFont(ofSize: 13)
    let key = TextSizeCache.Key(
      fontName: font.fontName,
      fontSize: font.pointSize,
      string: "Repeated",
      boldCharacterCount: 0,
    )

    #expect(cache.size(for: key) == cache.size(for: key))
  }

  @MainActor
  @Test
  func sizeReturnsZeroForMissingFont() {
    let cache = TextSizeCache()

    #expect(cache.size(for: .init(
      fontName: "Missing Font",
      fontSize: 13,
      string: "Hello",
      boldCharacterCount: 0,
    )) == .zero)
  }

  @MainActor
  @Test
  func sizeAppliesBoldCharacterCount() {
    let cache = TextSizeCache()
    let font = NSFont.systemFont(ofSize: 13)
    let string = "Hello"
    let boldCharacterCount = 2
    let key = TextSizeCache.Key(
      fontName: font.fontName,
      fontSize: font.pointSize,
      string: string,
      boldCharacterCount: boldCharacterCount,
    )
    let attributedString = NSMutableAttributedString(
      string: string,
      attributes: [.font: font],
    )
    attributedString.addAttribute(
      .font,
      value: NSFont.boldSystemFont(ofSize: font.pointSize),
      range: NSRange(location: 0, length: boldCharacterCount),
    )
    let expectedSize = attributedString.size()

    #expect(cache.size(for: key) == .init(
      width: ceil(expectedSize.width),
      height: ceil(expectedSize.height),
    ))
  }
}
