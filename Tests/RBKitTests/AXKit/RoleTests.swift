import Testing
@testable import AXKit

@Suite
struct `Role Tests` {
  @Test
  func `roles have expected raw values`() {
    let roles: [(Role, String)] = [
      (.application, "AXApplication"),
      (.browser, "AXBrowser"),
      (.busyIndicator, "AXBusyIndicator"),
      (.button, "AXButton"),
      (.cell, "AXCell"),
      (.checkBox, "AXCheckBox"),
      (.colorWell, "AXColorWell"),
      (.column, "AXColumn"),
      (.comboBox, "AXComboBox"),
      (.dateField, "AXDateField"),
      (.disclosureTriangle, "AXDisclosureTriangle"),
      (.dockItem, "AXDockItem"),
      (.drawer, "AXDrawer"),
      (.grid, "AXGrid"),
      (.group, "AXGroup"),
      (.growArea, "AXGrowArea"),
      (.handle, "AXHandle"),
      (.heading, "AXHeading"),
      (.helpTag, "AXHelpTag"),
      (.image, "AXImage"),
      (.imageMap, "AXImageMap"),
      (.incrementor, "AXIncrementor"),
      (.layoutArea, "AXLayoutArea"),
      (.layoutItem, "AXLayoutItem"),
      (.levelIndicator, "AXLevelIndicator"),
      (.link, "AXLink"),
      (.list, "AXList"),
      (.matte, "AXMatte"),
      (.menu, "AXMenu"),
      (.menuBar, "AXMenuBar"),
      (.menuBarItem, "AXMenuBarItem"),
      (.menuButton, "AXMenuButton"),
      (.menuItem, "AXMenuItem"),
      (.outline, "AXOutline"),
      (.popUpButton, "AXPopUpButton"),
      (.popover, "AXPopover"),
      (.progressIndicator, "AXProgressIndicator"),
      (.radioButton, "AXRadioButton"),
      (.radioGroup, "AXRadioGroup"),
      (.relevanceIndicator, "AXRelevanceIndicator"),
      (.row, "AXRow"),
      (.ruler, "AXRuler"),
      (.rulerMarker, "AXRulerMarker"),
      (.scrollArea, "AXScrollArea"),
      (.scrollBar, "AXScrollBar"),
      (.sheet, "AXSheet"),
      (.slider, "AXSlider"),
      (.sortButton, "AXSortButton"),
      (.splitGroup, "AXSplitGroup"),
      (.splitter, "AXSplitter"),
      (.staticText, "AXStaticText"),
      (.systemWide, "AXSystemWide"),
      (.tabGroup, "AXTabGroup"),
      (.table, "AXTable"),
      (.textArea, "AXTextArea"),
      (.textField, "AXTextField"),
      (.timeField, "AXTimeField"),
      (.toolbar, "AXToolbar"),
      (.unknown, "AXUnknown"),
      (.valueIndicator, "AXValueIndicator"),
      (.webArea, "AXWebArea"),
      (.window, "AXWindow"),
    ]

    for (role, rawValue) in roles {
      #expect(role.rawValue == rawValue)
    }
  }

  @Test
  func `coalescing raw value returns unknown for unrecognized role`() {
    #expect(Role(coalescingRawValue: "AXMadeUpRole") == .unknown)
    #expect(Role(coalescingRawValue: "AXButton") == .button)
  }
}
