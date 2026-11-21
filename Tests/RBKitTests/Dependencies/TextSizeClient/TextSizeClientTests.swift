import AppKit
import Testing

@testable import RBKit

@Suite(.serialized)
struct TextSizeClientTests {
  @MainActor
  @Test
  func liveValueReturnsCachedTextSizes() {
    let client = TextSizeClient.liveValue

    for textSize in [10.0, 13.0, 20.0, 24.0] {
      let font = NSFont.systemFont(ofSize: textSize)
      let key = TextSizeCache.Key(
        fontName: font.fontName,
        fontSize: font.pointSize,
        string: "x",
        boldCharacterCount: 0,
      )
      let expected = Double(
        ceil(
          NSAttributedString(
            string: "x",
            attributes: [.font: font],
          )
          .size()
          .height
        )
      )

      #expect(Double(client.size(key).height) == expected)
      #expect(Double(client.size(key).height) == expected)
    }
  }
}
