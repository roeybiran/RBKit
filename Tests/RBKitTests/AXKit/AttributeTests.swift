import Testing
import Foundation
@testable import AXKit

struct AttributeTests {

  @Test
  func staticVarAlternateUIVisible_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.alternateUIVisible
    #expect(attribute.name == "AXAlternateUIVisible")
  }

  @Test
  func staticVarAttributedStringForRangeParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<NSAttributedString>.attributedStringForRangeParameterized
    #expect(attribute.name == "AXAttributedStringForRange")
  }

  @Test
  func staticVarBoundsForRangeParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CGRect>.boundsForRangeParameterized
    #expect(attribute.name == "AXBoundsForRange")
  }

  @Test
  func staticVarCellForColumnAndRowParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.cellForColumnAndRowParameterized
    #expect(attribute.name == "AXCellForColumnAndRow")
  }

  @Test
  func staticVarClearButton_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.clearButton
    #expect(attribute.name == "AXClearButton")
  }

  @Test
  func staticVarColumnCount_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.columnCount
    #expect(attribute.name == "AXColumnCount")
  }

  @Test
  func staticVarColumnHeaderUIElements_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.columnHeaderUIElements
    #expect(attribute.name == "AXColumnHeaderUIElements")
  }

  @Test
  func staticVarColumnIndexRange_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<NSRange>.columnIndexRange
    #expect(attribute.name == "AXColumnIndexRange")
  }

  @Test
  func staticVarColumnTitles_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<[String]>.columnTitles
    #expect(attribute.name == "AXColumnTitles")
  }

  @Test
  func staticVarCriticalValue_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.criticalValue
    #expect(attribute.name == "AXCriticalValue")
  }

  @Test
  func staticVarDescription_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.description
    #expect(attribute.name == "AXDescription")
  }

  @Test
  func staticVarDisclosing_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.disclosing
    #expect(attribute.name == "AXDisclosing")
  }

  @Test
  func staticVarDisclosureLevel_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.disclosureLevel
    #expect(attribute.name == "AXDisclosureLevel")
  }

  @Test
  func staticVarDocument_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.document
    #expect(attribute.name == "AXDocument")
  }

  @Test
  func staticVarEdited_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.edited
    #expect(attribute.name == "AXEdited")
  }

  @Test
  func staticVarElementBusy_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.elementBusy
    #expect(attribute.name == "AXElementBusy")
  }

  @Test
  func staticVarEnabled_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.enabled
    #expect(attribute.name == "AXEnabled")
  }

  @Test
  func staticVarExpanded_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.expanded
    #expect(attribute.name == "AXExpanded")
  }

  @Test
  func staticVarFilename_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.filename
    #expect(attribute.name == "AXFilename")
  }

  @Test
  func staticVarFocused_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.focused
    #expect(attribute.name == "AXFocused")
  }

  @Test
  func staticVarFrame_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CGRect>.frame
    #expect(attribute.name == "AXFrame")
  }

  @Test
  func staticVarFrontmost_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.frontmost
    #expect(attribute.name == "AXFrontmost")
  }

  @Test
  func staticVarHelp_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.help
    #expect(attribute.name == "AXHelp")
  }

  @Test
  func staticVarHidden_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.hidden
    #expect(attribute.name == "AXHidden")
  }

  @Test
  func staticVarHorizontalUnitDescription_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.horizontalUnitDescription
    #expect(attribute.name == "AXHorizontalUnitDescription")
  }

  @Test
  func staticVarHorizontalUnits_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.horizontalUnits
    #expect(attribute.name == "AXHorizontalUnits")
  }

  @Test
  func staticVarIdentifier_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.identifier
    #expect(attribute.name == "AXIdentifier")
  }

  @Test
  func staticVarIndex_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.index
    #expect(attribute.name == "AXIndex")
  }

  @Test
  func staticVarInsertionPointLineNumber_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.insertionPointLineNumber
    #expect(attribute.name == "AXInsertionPointLineNumber")
  }

  @Test
  func staticVarIsApplicationRunning_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.isApplicationRunning
    #expect(attribute.name == "AXIsApplicationRunning")
  }

  @Test
  func staticVarIsEditable_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.isEditable
    #expect(attribute.name == "AXIsEditable")
  }

  @Test
  func staticVarLabelValue_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.labelValue
    #expect(attribute.name == "AXLabelValue")
  }

  @Test
  func staticVarLayoutPointForScreenPointParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CGPoint>.layoutPointForScreenPointParameterized
    #expect(attribute.name == "AXLayoutPointForScreenPoint")
  }

  @Test
  func staticVarLayoutSizeForScreenSizeParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CGSize>.layoutSizeForScreenSizeParameterized
    #expect(attribute.name == "AXLayoutSizeForScreenSize")
  }

  @Test
  func staticVarLineForIndexParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.lineForIndexParameterized
    #expect(attribute.name == "AXLineForIndex")
  }

  @Test
  func staticVarMain_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.main
    #expect(attribute.name == "AXMain")
  }

  @Test
  func staticVarMarkerType_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.markerType
    #expect(attribute.name == "AXMarkerType")
  }

  @Test
  func staticVarMarkerTypeDescription_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.markerTypeDescription
    #expect(attribute.name == "AXMarkerTypeDescription")
  }

  @Test
  func staticVarMatteHole_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CGRect>.matteHole
    #expect(attribute.name == "AXMatteHole")
  }

  @Test
  func staticVarMenuItemCmdChar_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.menuItemCmdChar
    #expect(attribute.name == "AXMenuItemCmdChar")
  }

  @Test
  func staticVarMenuItemCmdGlyph_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.menuItemCmdGlyph
    #expect(attribute.name == "AXMenuItemCmdGlyph")
  }

  @Test
  func staticVarMenuItemCmdModifiers_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<UInt32>.menuItemCmdModifiers
    #expect(attribute.name == "AXMenuItemCmdModifiers")
  }

  @Test
  func staticVarMenuItemCmdVirtualKey_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.menuItemCmdVirtualKey
    #expect(attribute.name == "AXMenuItemCmdVirtualKey")
  }

  @Test
  func staticVarMenuItemMarkChar_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.menuItemMarkChar
    #expect(attribute.name == "AXMenuItemMarkChar")
  }

  @Test
  func staticVarMinimized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.minimized
    #expect(attribute.name == "AXMinimized")
  }

  @Test
  func staticVarModal_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.modal
    #expect(attribute.name == "AXModal")
  }

  @Test
  func staticVarNumberOfCharacters_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Int>.numberOfCharacters
    #expect(attribute.name == "AXNumberOfCharacters")
  }

  @Test
  func staticVarOrderedByRow_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.orderedByRow
    #expect(attribute.name == "AXOrderedByRow")
  }

  @Test
  func staticVarOrientation_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Orientation>.orientation
    #expect(attribute.name == "AXOrientation")
  }

  @Test
  func staticVarPlaceholderValue_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.placeholderValue
    #expect(attribute.name == "AXPlaceholderValue")
  }

  @Test
  func staticVarPosition_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CGPoint>.position
    #expect(attribute.name == "AXPosition")
  }

  @Test
  func staticVarRangeForIndexParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.rangeForIndexParameterized
    #expect(attribute.name == "AXRangeForIndex")
  }

  @Test
  func staticVarRangeForLineParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.rangeForLineParameterized
    #expect(attribute.name == "AXRangeForLine")
  }

  @Test
  func staticVarRangeForPositionParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.rangeForPositionParameterized
    #expect(attribute.name == "AXRangeForPosition")
  }

  @Test
  func staticVarRole_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.role
    #expect(attribute.name == "AXRole")
  }

  @Test
  func staticVarRoleDescription_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.roleDescription
    #expect(attribute.name == "AXRoleDescription")
  }

  @Test
  func staticVarRowCount_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.rowCount
    #expect(attribute.name == "AXRowCount")
  }

  @Test
  func staticVarRowHeaderUIElements_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.rowHeaderUIElements
    #expect(attribute.name == "AXRowHeaderUIElements")
  }

  @Test
  func staticVarRowIndexRange_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.rowIndexRange
    #expect(attribute.name == "AXRowIndexRange")
  }

  @Test
  func staticVarRTFForRangeParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.RTFForRangeParameterized
    #expect(attribute.name == "AXRTFForRange")
  }

  @Test
  func staticVarScreenPointForLayoutPointParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.screenPointForLayoutPointParameterized
    #expect(attribute.name == "AXScreenPointForLayoutPoint")
  }

  @Test
  func staticVarScreenSizeForLayoutSizeParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.screenSizeForLayoutSizeParameterized
    #expect(attribute.name == "AXScreenSizeForLayoutSize")
  }

  @Test
  func staticVarSearchButton_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.searchButton
    #expect(attribute.name == "AXSearchButton")
  }

  @Test
  func staticVarSelected_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.selected
    #expect(attribute.name == "AXSelected")
  }

  @Test
  func staticVarSelectedCells_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.selectedCells
    #expect(attribute.name == "AXSelectedCells")
  }

  @Test
  func staticVarSelectedText_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.selectedText
    #expect(attribute.name == "AXSelectedText")
  }

  @Test
  func staticVarSelectedTextRange_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CFRange>.selectedTextRange
    #expect(attribute.name == "AXSelectedTextRange")
  }

  @Test
  func staticVarSelectedTextRanges_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<[CFRange]>.selectedTextRanges
    #expect(attribute.name == "AXSelectedTextRanges")
  }

  @Test
  func staticVarSharedCharacterRange_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CFRange>.sharedCharacterRange
    #expect(attribute.name == "AXSharedCharacterRange")
  }

  @Test
  func staticVarSize_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CGSize>.size
    #expect(attribute.name == "AXSize")
  }

  @Test
  func staticVarSortDirection_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<SortDirection>.sortDirection
    #expect(attribute.name == "AXSortDirection")
  }

  @Test
  func staticVarStringForRangeParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.stringForRangeParameterized
    #expect(attribute.name == "AXStringForRange")
  }

  @Test
  func staticVarStyleRangeForIndexParameterized_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.styleRangeForIndexParameterized
    #expect(attribute.name == "AXStyleRangeForIndex")
  }

  @Test
  func staticVarSubrole_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.subrole
    #expect(attribute.name == "AXSubrole")
  }

  @Test
  func staticVarText_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.text
    #expect(attribute.name == "AXText")
  }

  @Test
  func staticVarTitle_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.title
    #expect(attribute.name == "AXTitle")
  }

  @Test
  func staticVarUnitDescription_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.unitDescription
    #expect(attribute.name == "AXUnitDescription")
  }

  @Test
  func staticVarUnits_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.units
    #expect(attribute.name == "AXUnits")
  }

  @Test
  func staticVarURL_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<URL>.URL
    #expect(attribute.name == "AXURL")
  }

  @Test
  func staticVarValue_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.value
    #expect(attribute.name == "AXValue")
  }

  @Test
  func staticVarValueDescription_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.valueDescription
    #expect(attribute.name == "AXValueDescription")
  }

  @Test
  func staticVarValueWraps_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Bool>.valueWraps
    #expect(attribute.name == "AXValueWraps")
  }

  @Test
  func staticVarVerticalUnitDescription_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.verticalUnitDescription
    #expect(attribute.name == "AXVerticalUnitDescription")
  }

  @Test
  func staticVarVerticalUnits_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.verticalUnits
    #expect(attribute.name == "AXVerticalUnits")
  }

  @Test
  func staticVarVisibleCells_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.visibleCells
    #expect(attribute.name == "AXVisibleCells")
  }

  @Test
  func staticVarVisibleCharacterRange_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<CFRange>.visibleCharacterRange
    #expect(attribute.name == "AXVisibleCharacterRange")
  }

  @Test
  func staticVarVisibleText_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.visibleText
    #expect(attribute.name == "AXVisibleText")
  }

  @Test
  func staticVarWarningValue_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.warningValue
    #expect(attribute.name == "AXWarningValue")
  }

  @Test
  func staticVarStatusLabel_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<String>.statusLabel
    #expect(attribute.name == "AXStatusLabel")
  }

  // MARK: - Static Functions

  @Test
  func staticFuncAllowedValues_always_shouldReturnCorrectAttribute() {
    let attribute: Attribute<[String]> = .allowedValues()
    #expect(attribute.name == "AXAllowedValues")
  }

  @Test
  func staticFuncHandles_always_shouldReturnCorrectAttribute() {
    let attribute: Attribute<[String]> = .handles()
    #expect(attribute.name == "AXHandles")
  }

  @Test
  func staticFuncMaxValue_always_shouldReturnCorrectAttribute() {
    let attribute: Attribute<Int> = .maxValue()
    #expect(attribute.name == "AXMaxValue")
  }

  @Test
  func staticFuncMinValue_always_shouldReturnCorrectAttribute() {
    let attribute: Attribute<Int> = .minValue()
    #expect(attribute.name == "AXMinValue")
  }

  @Test
  func staticFuncValueIncrement_always_shouldReturnCorrectAttribute() {
    let attribute: Attribute<Int> = .valueIncrement()
    #expect(attribute.name == "AXValueIncrement")
  }

  @Test
  func staticFuncServesAsTitleForUIElements_always_shouldReturnCorrectAttribute() {
    let attribute = Attribute<Any>.servesAsTitleForUIElements()
    #expect(attribute.name == "AXServesAsTitleForUIElements")
  }
}