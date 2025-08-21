import ApplicationServices

// MARK: - Attribute

// /System/Library/Accessibility/AccessibilityDefinitions.plist

public struct Attribute<T>: Equatable {
  // MARK: Lifecycle

  public init(_ name: AttributeName) {
    self.name = name.rawValue
  }

  public init(_ string: String) {
    name = string
  }

  public let name: String

  public static var alternateUIVisible: Attribute<Bool> { .init(.alternateUIVisible) }
  public static var attributedStringForRangeParameterized: Attribute<NSAttributedString> {
    .init(.attributedStringForRangeParameterized)
  }
  public static var boundsForRangeParameterized: Attribute<CGRect> { .init(.boundsForRangeParameterized) }
  public static var cellForColumnAndRowParameterized: Attribute<Any> { .init(.cellForColumnAndRowParameterized) }
  public static var clearButton: Attribute<Any> { .init(.clearButton) }
  public static var columnCount: Attribute<Int> { .init(.columnCount) }
  public static var columnHeaderUIElements: Attribute<Any> { .init(.columnHeaderUIElements) }
  public static var columnIndexRange: Attribute<CFRange> { .init(.columnIndexRange) }
  public static var columnTitles: Attribute<[String]> { .init(.columnTitles) }
  public static var criticalValue: Attribute<T> { .init(.criticalValue) }
  public static var description: Attribute<String> { .init(.description) }
  public static var disclosing: Attribute<Bool> { .init(.disclosing) }
  public static var disclosureLevel: Attribute<Int> { .init(.disclosureLevel) }
  public static var document: Attribute<String> { .init(.document) }
  public static var edited: Attribute<Bool> { .init(.edited) }
  public static var elementBusy: Attribute<Bool> { .init(.elementBusy) }
  public static var enabled: Attribute<Bool> { .init(.enabled) }
  public static var expanded: Attribute<Bool> { .init(.expanded) }
  public static var filename: Attribute<String> { .init(.filename) }
  public static var focused: Attribute<Bool> { .init(.focused) }
  public static var frame: Attribute<CGRect> { .init(.frame) }
  public static var frontmost: Attribute<Bool> { .init(.frontmost) }
  public static var help: Attribute<String> { .init(.help) }
  public static var hidden: Attribute<Bool> { .init(.hidden) }
  public static var horizontalUnitDescription: Attribute<String> { .init(.horizontalUnitDescription) }
  public static var horizontalUnits: Attribute<String> { .init(.horizontalUnits) }
  public static var identifier: Attribute<String> { .init(.identifier) }
  public static var index: Attribute<Int> { .init(.index) }
  public static var insertionPointLineNumber: Attribute<Int> { .init(.insertionPointLineNumber) }
  public static var isApplicationRunning: Attribute<Bool> { .init(.isApplicationRunning) }
  public static var isEditable: Attribute<Bool> { .init(.isEditable) }
  public static var labelValue: Attribute<Int> { .init(.labelValue) }
  public static var layoutPointForScreenPointParameterized: Attribute<CGPoint> { .init(.layoutPointForScreenPointParameterized) }
  public static var layoutSizeForScreenSizeParameterized: Attribute<CGSize> { .init(.layoutSizeForScreenSizeParameterized) }
  public static var lineForIndexParameterized: Attribute<Int> { .init(.lineForIndexParameterized) }
  public static var main: Attribute<Bool> { .init(.main) }
  public static var markerType: Attribute<String> { .init(.markerType) }
  public static var markerTypeDescription: Attribute<String> { .init(.markerTypeDescription) }
  public static var matteHole: Attribute<CGRect> { .init(.matteHole) }
  public static var menuItemCmdChar: Attribute<String> { .init(.menuItemCmdChar) }
  public static var menuItemCmdGlyph: Attribute<Int> { .init(.menuItemCmdGlyph) }
  // TODO: change to AXMenuItemModifiers?
  public static var menuItemCmdModifiers: Attribute<UInt32> { .init(.menuItemCmdModifiers) }
  public static var menuItemCmdVirtualKey: Attribute<Int> { .init(.menuItemCmdVirtualKey) }
  public static var menuItemMarkChar: Attribute<String> { .init(.menuItemMarkChar) }
  public static var minimized: Attribute<Bool> { .init(.minimized) }
  public static var modal: Attribute<Bool> { .init(.modal) }
  public static var numberOfCharacters: Attribute<Int> { .init(.numberOfCharacters) }
  public static var orderedByRow: Attribute<Any> { .init(.orderedByRow) }
  public static var orientation: Attribute<Orientation> { .init(.orientation) }
  public static var placeholderValue: Attribute<String> { .init(.placeholderValue) }
  public static var position: Attribute<CGPoint> { .init(.position) }
  public static var rangeForIndexParameterized: Attribute<Any> { .init(.rangeForIndexParameterized) }
  public static var rangeForLineParameterized: Attribute<Any> { .init(.rangeForLineParameterized) }
  public static var rangeForPositionParameterized: Attribute<Any> { .init(.rangeForPositionParameterized) }
  public static var role: Attribute<String> { .init(.role) }
  public static var roleDescription: Attribute<String> { .init(.roleDescription) }
  public static var rowCount: Attribute<Any> { .init(.rowCount) }
  public static var rowHeaderUIElements: Attribute<Any> { .init(.rowHeaderUIElements) }
  public static var rowIndexRange: Attribute<Any> { .init(.rowIndexRange) }
  public static var RTFForRangeParameterized: Attribute<Any> { .init(.RTFForRangeParameterized) }
  public static var screenPointForLayoutPointParameterized: Attribute<Any> { .init(.screenPointForLayoutPointParameterized) }
  public static var screenSizeForLayoutSizeParameterized: Attribute<Any> { .init(.screenSizeForLayoutSizeParameterized) }
  public static var searchButton: Attribute<Any> { .init(.searchButton) }
  public static var selected: Attribute<Bool> { .init(.selected) }
  public static var selectedCells: Attribute<Any> { .init(.selectedCells) }
  public static var selectedText: Attribute<String> { .init(.selectedText) }
  public static var selectedTextRange: Attribute<CFRange> { .init(.selectedTextRange) }
  public static var selectedTextRanges: Attribute<[CFRange]> { .init(.selectedTextRanges) }
  public static var sharedCharacterRange: Attribute<CFRange> { .init(.sharedCharacterRange) }
  public static var size: Attribute<CGSize> { .init(.size) }
  public static var sortDirection: Attribute<SortDirection> { .init(.sortDirection) }
  public static var stringForRangeParameterized: Attribute<Any> { .init(.stringForRangeParameterized) }
  public static var styleRangeForIndexParameterized: Attribute<Any> { .init(.styleRangeForIndexParameterized) }
  public static var subrole: Attribute<String> { .init(.subrole) }
  public static var text: Attribute<Any> { .init(.text) }
  public static var title: Attribute<String> { .init(.title) }
  public static var unitDescription: Attribute<Any> { .init(.unitDescription) }
  public static var units: Attribute<Any> { .init(.units) }
  public static var URL: Attribute<URL> { .init(.URL) }
  public static var value: Attribute<T> { .init(.value) }
  public static var valueDescription: Attribute<String> { .init(.valueDescription) }
  public static var valueWraps: Attribute<Bool> { .init(.valueWraps) }
  public static var verticalUnitDescription: Attribute<Any> { .init(.verticalUnitDescription) }
  public static var verticalUnits: Attribute<Any> { .init(.verticalUnits) }
  public static var visibleCells: Attribute<Any> { .init(.visibleCells) }
  public static var visibleCharacterRange: Attribute<CFRange> { .init(.visibleCharacterRange) }
  public static var visibleText: Attribute<Any> { .init(.visibleText) }
  public static var warningValue: Attribute<Any> { .init(.warningValue) }
  public static var statusLabel: Attribute<String> { .init(.statusLabel) }

  public static func allowedValues<A>() -> Attribute<[A]> { .init(.allowedValues) }
  public static func handles<A>() -> Attribute<[A]> { .init(.handles) }
  public static func maxValue<A>() -> Attribute<A> { .init(.maxValue) }
  public static func minValue<A>() -> Attribute<A> { .init(.minValue) }
  public static func valueIncrement<A>() -> Attribute<A> { .init(.valueIncrement) }

  /// As of macOS Sonoma, this attribute returns a single AXUIElement, instead of an array like it used to. This is either a bug on Apple’s end, or undocumented breaking change. Filed as **FB12308385**.
  public static func servesAsTitleForUIElements() -> Attribute<Any> { .init(.servesAsTitleForUIElements) }
}
