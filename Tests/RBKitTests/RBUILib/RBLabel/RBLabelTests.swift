import AppKit
import Dependencies
import Testing

@testable import RBKit

@MainActor
struct RBLabelTests {
  @Test
  func intrinsicContentSizeMatchesTextOnlyLayoutWhenImageIsNil() {
    let label = withDependencies {
      $0.textSizeClient = .liveValue
    } operation: {
      RBLabel(frame: .init(x: 0, y: 0, width: 120, height: 24))
    }
    label.stringValue = "Test Title"

    let measuredSize = label.measuredTextFittingSize()

    #expect(label.intrinsicContentSize == .init(
      width: ceil((label.horizontalPadding * 2) + measuredSize.width),
      height: ceil(measuredSize.height + (label.verticalPadding * 2)),
    ))
  }

  @Test
  func intrinsicContentSizeIncludesImageWidthWhenImageIsPresent() {
    let label = withDependencies {
      $0.textSizeClient = .liveValue
    } operation: {
      RBLabel(frame: .init(x: 0, y: 0, width: 120, height: 24))
    }
    label.stringValue = "Test Title"
    label.image = NSImage(size: .init(width: 16, height: 16))

    let measuredSize = label.measuredTextFittingSize()
    let expectedHeight = ceil(max(measuredSize.height, 16) + (label.verticalPadding * 2))
    let expectedImageWidth = max(0, expectedHeight - (label.verticalPadding * 2))

    #expect(label.intrinsicContentSize == .init(
      width: ceil((label.horizontalPadding * 2) + expectedImageWidth + measuredSize.width),
      height: expectedHeight,
    ))
  }

  @Test
  func imageOnlyLabelUsesImageHeightForIntrinsicContentSize() {
    let label = withDependencies {
      $0.textSizeClient = .liveValue
    } operation: {
      RBLabel(frame: .init(x: 0, y: 0, width: 24, height: 24))
    }
    label.image = NSImage(size: .init(width: 20, height: 20))

    #expect(label.intrinsicContentSize == .init(width: 28, height: 24))
  }

  @Test
  func accessibilityValueMatchesStringValue() {
    let label = RBLabel()
    label.stringValue = "Recent"

    #expect(label.accessibilityValue() == "Recent")
  }

  @Test
  func selectionStateSwitchesTintColor() {
    let label = RBLabel()
    label.contentColor = .systemOrange

    #expect(label.contentTintColor.isEqual(NSColor.systemOrange))

    label.isSelected = true

    #expect(label.contentTintColor.isEqual(NSColor.alternateSelectedControlTextColor))
  }
}
