import Testing
@testable import AXKit

@Suite
struct `SubRole Tests` {
  @Test
  func `subroles have expected raw values`() {
    let subroles: [(SubRole, String)] = [
      (.applicationDockItem, "AXApplicationDockItem"),
      (.closeButton, "AXCloseButton"),
      (.contentList, "AXContentList"),
      (.decrementArrow, "AXDecrementArrow"),
      (.decrementPage, "AXDecrementPage"),
      (.definitionList, "AXDefinitionList"),
      (.descriptionList, "AXDescriptionList"),
      (.dialog, "AXDialog"),
      (.dockExtraDockItem, "AXDockExtraDockItem"),
      (.documentDockItem, "AXDocumentDockItem"),
      (.floatingWindow, "AXFloatingWindow"),
      (.folderDockItem, "AXFolderDockItem"),
      (.fullScreenButton, "AXFullScreenButton"),
      (.incrementArrow, "AXIncrementArrow"),
      (.incrementPage, "AXIncrementPage"),
      (.minimizeButton, "AXMinimizeButton"),
      (.minimizedWindowDockItem, "AXMinimizedWindowDockItem"),
      (.outlineRow, "AXOutlineRow"),
      (.processSwitcherList, "AXProcessSwitcherList"),
      (.ratingIndicator, "AXRatingIndicator"),
      (.searchField, "AXSearchField"),
      (.secureTextField, "AXSecureTextField"),
      (.separatorDockItem, "AXSeparatorDockItem"),
      (.sortButton, "AXSortButton"),
      (.standardWindow, "AXStandardWindow"),
      (.`switch`, "AXSwitch"),
      (.systemDialog, "AXSystemDialog"),
      (.systemFloatingWindow, "AXSystemFloatingWindow"),
      (.tableRow, "AXTableRow"),
      (.textAttachment, "AXTextAttachment"),
      (.textLink, "AXTextLink"),
      (.timeline, "AXTimeline"),
      (.toggle, "AXToggle"),
      (.toolbarButton, "AXToolbarButton"),
      (.trashDockItem, "AXTrashDockItem"),
      (.URLDockItem, "AXURLDockItem"),
      (.unknown, "AXUnknown"),
      (.zoomButton, "AXZoomButton"),
      (.collectionList, "AXCollectionList"),
      (.decorative, "AXDecorative"),
      (.menuBarExtra, "AXMenuExtra"),
      (.notificationCenterBanner, "AXNotificationCenterBanner"),
      (.sectionList, "AXSectionList"),
      (.suggestion, "AXSuggestion"),
      (.tabButton, "AXTabButton"),
    ]

    for (subrole, rawValue) in subroles {
      #expect(subrole.rawValue == rawValue)
    }
  }
}
