import Testing
import Foundation
@testable import AXKit

struct `Attribute Tests` {
  @Test
  func `alternateUIVisible == AXAlternateUIVisible`() {
    let attribute = Attribute<Bool>.alternateUIVisible
    #expect(attribute.name == "AXAlternateUIVisible")
  }

  @Test
  func `attributedStringForRangeParameterized == AXAttributedStringForRange`() {
    let attribute = Attribute<NSAttributedString>.attributedStringForRangeParameterized
    #expect(attribute.name == "AXAttributedStringForRange")
  }

  @Test
  func `boundsForRangeParameterized == AXBoundsForRange`() {
    let attribute = Attribute<CGRect>.boundsForRangeParameterized
    #expect(attribute.name == "AXBoundsForRange")
  }

  @Test
  func `cellForColumnAndRowParameterized == AXCellForColumnAndRow`() {
    let attribute = Attribute<Any>.cellForColumnAndRowParameterized
    #expect(attribute.name == "AXCellForColumnAndRow")
  }

  @Test
  func `clearButton == AXClearButton`() {
    let attribute = Attribute<Any>.clearButton
    #expect(attribute.name == "AXClearButton")
  }

  @Test
  func `columnCount == AXColumnCount`() {
    let attribute = Attribute<Int>.columnCount
    #expect(attribute.name == "AXColumnCount")
  }

  @Test
  func `columnHeaderUIElements == AXColumnHeaderUIElements`() {
    let attribute = Attribute<Any>.columnHeaderUIElements
    #expect(attribute.name == "AXColumnHeaderUIElements")
  }

  @Test
  func `columnIndexRange == AXColumnIndexRange`() {
    let attribute = Attribute<NSRange>.columnIndexRange
    #expect(attribute.name == "AXColumnIndexRange")
  }

  @Test
  func `columnTitles == AXColumnTitles`() {
    let attribute = Attribute<[String]>.columnTitles
    #expect(attribute.name == "AXColumnTitles")
  }

  @Test
  func `criticalValue == AXCriticalValue`() {
    let attribute = Attribute<String>.criticalValue
    #expect(attribute.name == "AXCriticalValue")
  }

  @Test
  func `description == AXDescription`() {
    let attribute = Attribute<String>.description
    #expect(attribute.name == "AXDescription")
  }

  @Test
  func `disclosing == AXDisclosing`() {
    let attribute = Attribute<Bool>.disclosing
    #expect(attribute.name == "AXDisclosing")
  }

  @Test
  func `disclosureLevel == AXDisclosureLevel`() {
    let attribute = Attribute<Int>.disclosureLevel
    #expect(attribute.name == "AXDisclosureLevel")
  }

  @Test
  func `document == AXDocument`() {
    let attribute = Attribute<String>.document
    #expect(attribute.name == "AXDocument")
  }

  @Test
  func `edited == AXEdited`() {
    let attribute = Attribute<Bool>.edited
    #expect(attribute.name == "AXEdited")
  }

  @Test
  func `elementBusy == AXElementBusy`() {
    let attribute = Attribute<Bool>.elementBusy
    #expect(attribute.name == "AXElementBusy")
  }

  @Test
  func `enabled == AXEnabled`() {
    let attribute = Attribute<Bool>.enabled
    #expect(attribute.name == "AXEnabled")
  }

  @Test
  func `expanded == AXExpanded`() {
    let attribute = Attribute<Bool>.expanded
    #expect(attribute.name == "AXExpanded")
  }

  @Test
  func `filename == AXFilename`() {
    let attribute = Attribute<String>.filename
    #expect(attribute.name == "AXFilename")
  }

  @Test
  func `focused == AXFocused`() {
    let attribute = Attribute<Bool>.focused
    #expect(attribute.name == "AXFocused")
  }

  @Test
  func `frame == AXFrame`() {
    let attribute = Attribute<CGRect>.frame
    #expect(attribute.name == "AXFrame")
  }

  @Test
  func `frontmost == AXFrontmost`() {
    let attribute = Attribute<Bool>.frontmost
    #expect(attribute.name == "AXFrontmost")
  }

  @Test
  func `help == AXHelp`() {
    let attribute = Attribute<String>.help
    #expect(attribute.name == "AXHelp")
  }

  @Test
  func `hidden == AXHidden`() {
    let attribute = Attribute<Bool>.hidden
    #expect(attribute.name == "AXHidden")
  }

  @Test
  func `horizontalUnitDescription == AXHorizontalUnitDescription`() {
    let attribute = Attribute<String>.horizontalUnitDescription
    #expect(attribute.name == "AXHorizontalUnitDescription")
  }

  @Test
  func `horizontalUnits == AXHorizontalUnits`() {
    let attribute = Attribute<String>.horizontalUnits
    #expect(attribute.name == "AXHorizontalUnits")
  }

  @Test
  func `identifier == AXIdentifier`() {
    let attribute = Attribute<String>.identifier
    #expect(attribute.name == "AXIdentifier")
  }

  @Test
  func `index == AXIndex`() {
    let attribute = Attribute<Int>.index
    #expect(attribute.name == "AXIndex")
  }

  @Test
  func `insertionPointLineNumber == AXInsertionPointLineNumber`() {
    let attribute = Attribute<Int>.insertionPointLineNumber
    #expect(attribute.name == "AXInsertionPointLineNumber")
  }

  @Test
  func `isApplicationRunning == AXIsApplicationRunning`() {
    let attribute = Attribute<Bool>.isApplicationRunning
    #expect(attribute.name == "AXIsApplicationRunning")
  }

  @Test
  func `isEditable == AXIsEditable`() {
    let attribute = Attribute<Bool>.isEditable
    #expect(attribute.name == "AXIsEditable")
  }

  @Test
  func `labelValue == AXLabelValue`() {
    let attribute = Attribute<Int>.labelValue
    #expect(attribute.name == "AXLabelValue")
  }

  @Test
  func `layoutPointForScreenPointParameterized == AXLayoutPointForScreenPoint`() {
    let attribute = Attribute<CGPoint>.layoutPointForScreenPointParameterized
    #expect(attribute.name == "AXLayoutPointForScreenPoint")
  }

  @Test
  func `layoutSizeForScreenSizeParameterized == AXLayoutSizeForScreenSize`() {
    let attribute = Attribute<CGSize>.layoutSizeForScreenSizeParameterized
    #expect(attribute.name == "AXLayoutSizeForScreenSize")
  }

  @Test
  func `lineForIndexParameterized == AXLineForIndex`() {
    let attribute = Attribute<Int>.lineForIndexParameterized
    #expect(attribute.name == "AXLineForIndex")
  }

  @Test
  func `main == AXMain`() {
    let attribute = Attribute<Bool>.main
    #expect(attribute.name == "AXMain")
  }

  @Test
  func `markerType == AXMarkerType`() {
    let attribute = Attribute<String>.markerType
    #expect(attribute.name == "AXMarkerType")
  }

  @Test
  func `markerTypeDescription == AXMarkerTypeDescription`() {
    let attribute = Attribute<String>.markerTypeDescription
    #expect(attribute.name == "AXMarkerTypeDescription")
  }

  @Test
  func `matteHole == AXMatteHole`() {
    let attribute = Attribute<CGRect>.matteHole
    #expect(attribute.name == "AXMatteHole")
  }

  @Test
  func `menuItemCmdChar == AXMenuItemCmdChar`() {
    let attribute = Attribute<String>.menuItemCmdChar
    #expect(attribute.name == "AXMenuItemCmdChar")
  }

  @Test
  func `menuItemCmdGlyph == AXMenuItemCmdGlyph`() {
    let attribute = Attribute<Int>.menuItemCmdGlyph
    #expect(attribute.name == "AXMenuItemCmdGlyph")
  }

  @Test
  func `menuItemCmdModifiers == AXMenuItemCmdModifiers`() {
    let attribute = Attribute<UInt32>.menuItemCmdModifiers
    #expect(attribute.name == "AXMenuItemCmdModifiers")
  }

  @Test
  func `menuItemCmdVirtualKey == AXMenuItemCmdVirtualKey`() {
    let attribute = Attribute<Int>.menuItemCmdVirtualKey
    #expect(attribute.name == "AXMenuItemCmdVirtualKey")
  }

  @Test
  func `menuItemMarkChar == AXMenuItemMarkChar`() {
    let attribute = Attribute<String>.menuItemMarkChar
    #expect(attribute.name == "AXMenuItemMarkChar")
  }

  @Test
  func `minimized == AXMinimized`() {
    let attribute = Attribute<Bool>.minimized
    #expect(attribute.name == "AXMinimized")
  }

  @Test
  func `modal == AXModal`() {
    let attribute = Attribute<Bool>.modal
    #expect(attribute.name == "AXModal")
  }

  @Test
  func `numberOfCharacters == AXNumberOfCharacters`() {
    let attribute = Attribute<Int>.numberOfCharacters
    #expect(attribute.name == "AXNumberOfCharacters")
  }

  @Test
  func `orderedByRow == AXOrderedByRow`() {
    let attribute = Attribute<Any>.orderedByRow
    #expect(attribute.name == "AXOrderedByRow")
  }

  @Test
  func `orientation == AXOrientation`() {
    let attribute = Attribute<Orientation>.orientation
    #expect(attribute.name == "AXOrientation")
  }

  @Test
  func `placeholderValue == AXPlaceholderValue`() {
    let attribute = Attribute<String>.placeholderValue
    #expect(attribute.name == "AXPlaceholderValue")
  }

  @Test
  func `position == AXPosition`() {
    let attribute = Attribute<CGPoint>.position
    #expect(attribute.name == "AXPosition")
  }

  @Test
  func `rangeForIndexParameterized == AXRangeForIndex`() {
    let attribute = Attribute<Any>.rangeForIndexParameterized
    #expect(attribute.name == "AXRangeForIndex")
  }

  @Test
  func `rangeForLineParameterized == AXRangeForLine`() {
    let attribute = Attribute<Any>.rangeForLineParameterized
    #expect(attribute.name == "AXRangeForLine")
  }

  @Test
  func `rangeForPositionParameterized == AXRangeForPosition`() {
    let attribute = Attribute<Any>.rangeForPositionParameterized
    #expect(attribute.name == "AXRangeForPosition")
  }

  @Test
  func `role == AXRole`() {
    let attribute = Attribute<String>.role
    #expect(attribute.name == "AXRole")
  }

  @Test
  func `roleDescription == AXRoleDescription`() {
    let attribute = Attribute<String>.roleDescription
    #expect(attribute.name == "AXRoleDescription")
  }

  @Test
  func `rowCount == AXRowCount`() {
    let attribute = Attribute<Any>.rowCount
    #expect(attribute.name == "AXRowCount")
  }

  @Test
  func `rowHeaderUIElements == AXRowHeaderUIElements`() {
    let attribute = Attribute<Any>.rowHeaderUIElements
    #expect(attribute.name == "AXRowHeaderUIElements")
  }

  @Test
  func `rowIndexRange == AXRowIndexRange`() {
    let attribute = Attribute<Any>.rowIndexRange
    #expect(attribute.name == "AXRowIndexRange")
  }

  @Test
  func `RTFForRangeParameterized == AXRTFForRange`() {
    let attribute = Attribute<Any>.RTFForRangeParameterized
    #expect(attribute.name == "AXRTFForRange")
  }

  @Test
  func `screenPointForLayoutPointParameterized == AXScreenPointForLayoutPoint`() {
    let attribute = Attribute<Any>.screenPointForLayoutPointParameterized
    #expect(attribute.name == "AXScreenPointForLayoutPoint")
  }

  @Test
  func `screenSizeForLayoutSizeParameterized == AXScreenSizeForLayoutSize`() {
    let attribute = Attribute<Any>.screenSizeForLayoutSizeParameterized
    #expect(attribute.name == "AXScreenSizeForLayoutSize")
  }

  @Test
  func `searchButton == AXSearchButton`() {
    let attribute = Attribute<Any>.searchButton
    #expect(attribute.name == "AXSearchButton")
  }

  @Test
  func `selected == AXSelected`() {
    let attribute = Attribute<Bool>.selected
    #expect(attribute.name == "AXSelected")
  }

  @Test
  func `selectedCells == AXSelectedCells`() {
    let attribute = Attribute<Any>.selectedCells
    #expect(attribute.name == "AXSelectedCells")
  }

  @Test
  func `selectedText == AXSelectedText`() {
    let attribute = Attribute<String>.selectedText
    #expect(attribute.name == "AXSelectedText")
  }

  @Test
  func `selectedTextRange == AXSelectedTextRange`() {
    let attribute = Attribute<CFRange>.selectedTextRange
    #expect(attribute.name == "AXSelectedTextRange")
  }

  @Test
  func `selectedTextRanges == AXSelectedTextRanges`() {
    let attribute = Attribute<[CFRange]>.selectedTextRanges
    #expect(attribute.name == "AXSelectedTextRanges")
  }

  @Test
  func `sharedCharacterRange == AXSharedCharacterRange`() {
    let attribute = Attribute<CFRange>.sharedCharacterRange
    #expect(attribute.name == "AXSharedCharacterRange")
  }

  @Test
  func `size == AXSize`() {
    let attribute = Attribute<CGSize>.size
    #expect(attribute.name == "AXSize")
  }

  @Test
  func `sortDirection == AXSortDirection`() {
    let attribute = Attribute<SortDirection>.sortDirection
    #expect(attribute.name == "AXSortDirection")
  }

  @Test
  func `stringForRangeParameterized == AXStringForRange`() {
    let attribute = Attribute<Any>.stringForRangeParameterized
    #expect(attribute.name == "AXStringForRange")
  }

  @Test
  func `styleRangeForIndexParameterized == AXStyleRangeForIndex`() {
    let attribute = Attribute<Any>.styleRangeForIndexParameterized
    #expect(attribute.name == "AXStyleRangeForIndex")
  }

  @Test
  func `subrole == AXSubrole`() {
    let attribute = Attribute<String>.subrole
    #expect(attribute.name == "AXSubrole")
  }

  @Test
  func `text == AXText`() {
    let attribute = Attribute<Any>.text
    #expect(attribute.name == "AXText")
  }

  @Test
  func `title == AXTitle`() {
    let attribute = Attribute<String>.title
    #expect(attribute.name == "AXTitle")
  }

  @Test
  func `unitDescription == AXUnitDescription`() {
    let attribute = Attribute<Any>.unitDescription
    #expect(attribute.name == "AXUnitDescription")
  }

  @Test
  func `units == AXUnits`() {
    let attribute = Attribute<Any>.units
    #expect(attribute.name == "AXUnits")
  }

  @Test
  func `URL == AXURL`() {
    let attribute = Attribute<URL>.URL
    #expect(attribute.name == "AXURL")
  }

  @Test
  func `value == AXValue`() {
    let attribute = Attribute<String>.value
    #expect(attribute.name == "AXValue")
  }

  @Test
  func `valueDescription == AXValueDescription`() {
    let attribute = Attribute<String>.valueDescription
    #expect(attribute.name == "AXValueDescription")
  }

  @Test
  func `valueWraps == AXValueWraps`() {
    let attribute = Attribute<Bool>.valueWraps
    #expect(attribute.name == "AXValueWraps")
  }

  @Test
  func `verticalUnitDescription == AXVerticalUnitDescription`() {
    let attribute = Attribute<Any>.verticalUnitDescription
    #expect(attribute.name == "AXVerticalUnitDescription")
  }

  @Test
  func `verticalUnits == AXVerticalUnits`() {
    let attribute = Attribute<Any>.verticalUnits
    #expect(attribute.name == "AXVerticalUnits")
  }

  @Test
  func `visibleCells == AXVisibleCells`() {
    let attribute = Attribute<Any>.visibleCells
    #expect(attribute.name == "AXVisibleCells")
  }

  @Test
  func `visibleCharacterRange == AXVisibleCharacterRange`() {
    let attribute = Attribute<CFRange>.visibleCharacterRange
    #expect(attribute.name == "AXVisibleCharacterRange")
  }

  @Test
  func `visibleText == AXVisibleText`() {
    let attribute = Attribute<Any>.visibleText
    #expect(attribute.name == "AXVisibleText")
  }

  @Test
  func `warningValue == AXWarningValue`() {
    let attribute = Attribute<Any>.warningValue
    #expect(attribute.name == "AXWarningValue")
  }

  @Test
  func `statusLabel == AXStatusLabel`() {
    let attribute = Attribute<String>.statusLabel
    #expect(attribute.name == "AXStatusLabel")
  }

  // MARK: - Static Functions

  @Test
  func `allowedValues() == AXAllowedValues`() {
    let attribute: Attribute<[String]> = .allowedValues()
    #expect(attribute.name == "AXAllowedValues")
  }

  @Test
  func `handles() == AXHandles`() {
    let attribute: Attribute<[String]> = .handles()
    #expect(attribute.name == "AXHandles")
  }

  @Test
  func `maxValue() == AXMaxValue`() {
    let attribute: Attribute<Int> = .maxValue()
    #expect(attribute.name == "AXMaxValue")
  }

  @Test
  func `minValue() == AXMinValue`() {
    let attribute: Attribute<Int> = .minValue()
    #expect(attribute.name == "AXMinValue")
  }

  @Test
  func `valueIncrement() == AXValueIncrement`() {
    let attribute: Attribute<Int> = .valueIncrement()
    #expect(attribute.name == "AXValueIncrement")
  }

  @Test
  func `servesAsTitleForUIElements() == AXServesAsTitleForUIElements`() {
    let attribute = Attribute<Any>.servesAsTitleForUIElements()
    #expect(attribute.name == "AXServesAsTitleForUIElements")
  }
}
