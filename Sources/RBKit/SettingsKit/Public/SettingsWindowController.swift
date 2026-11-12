import AppKit
import Combine
import Sharing

// MARK: - SettingsWindowController

/// A master-detail settings window: a sidebar listing the panes, and the selected pane's
/// content (a grouped `Form`) in the detail area, with back/forward
/// navigation in the toolbar.
///
/// With a single pane, the sidebar and toolbar are omitted.
open class SettingsWindowController: NSWindowController, NSToolbarDelegate {

  // MARK: Lifecycle

  public convenience init() {
    self.init(windowNibName: "")
  }

  public convenience init(_ panes: [Pane]) {
    self.init()
    setPanes(panes)
  }

  // MARK: Open

  open class var defaultContentSize: NSSize {
    NSSize(width: 720, height: 560)
  }

  open class var minimumContentSize: NSSize {
    NSSize(width: 600, height: 360)
  }

  // MARK: Public

  override public func loadWindow() {
    let window = NSWindow(
      contentRect: NSRect(origin: .zero, size: Self.defaultContentSize),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: true,
    )
    window.toolbarStyle = .unified
    window.collectionBehavior.insert(.fullScreenNone)
    self.window = window
  }

  public override func windowDidLoad() {
    assert(!panes.isEmpty, "you must provide at least one pane")
    assertUniqueLabels(panes)

    guard let window else { return }
    window.autorecalculatesKeyViewLoop = true
    window.contentMinSize = Self.minimumContentSize

    rebuildContent()

    let autosaveName = Self.frameAutosaveName
    if !window.setFrameUsingName(autosaveName) {
      window.setContentSize(Self.defaultContentSize)
      window.center()
    }
    windowFrameAutosaveName = autosaveName

    let storedIndex = storedSelectedTabIndex
    selectPane(at: panes.indices.contains(storedIndex) ? storedIndex : 0, recordingHistory: false)

    isSettingsWindowFloatingCancellable = $isSettingsWindowFloating.publisher
      .sink { [weak self] isSettingsWindowFloating in
        self?.window?.level = isSettingsWindowFloating ? .floating : .normal
      }
  }

  public func setPanes(_ panes: [Pane]) {
    assert(!panes.isEmpty, "you must provide at least one pane")
    assertUniqueLabels(panes)

    self.panes = panes
    backStack.removeAll()
    forwardStack.removeAll()

    guard isWindowLoaded else { return }

    rebuildContent()
    selectPane(at: panes.indices.contains(selectedPaneIndex) ? selectedPaneIndex : 0, recordingHistory: false)
  }

  public override func doCommand(by selector: Selector) {
    if selector == #selector(NSSavePanel.cancel(_:)) {
      close()
    } else {
      super.doCommand(by: selector)
    }
  }

  public func openPane(identifier: String) {
    guard let index = panes.firstIndex(where: { $0.identifier == identifier }) else { return }
    _ = window
    selectPane(at: index)
  }

  public func toolbar(
    _: NSToolbar,
    itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
    willBeInsertedIntoToolbar _: Bool,
  ) -> NSToolbarItem? {
    guard itemIdentifier == .settingsNavigation else { return nil }
    let group = NSToolbarItemGroup(
      itemIdentifier: itemIdentifier,
      images: [
        NSImage(systemSymbolName: "chevron.backward", accessibilityDescription: "Back")!,
        NSImage(systemSymbolName: "chevron.forward", accessibilityDescription: "Forward")!,
      ],
      selectionMode: .momentary,
      labels: ["Back", "Forward"],
      target: self,
      action: #selector(navigate(_:)),
    )
    group.isNavigational = true
    group.autovalidates = false
    for item in group.subitems {
      item.autovalidates = false
    }
    navigationItem = group
    updateNavigationItem()
    return group
  }

  public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
    [.sidebarTrackingSeparator, .settingsNavigation]
  }

  public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    toolbarDefaultItemIdentifiers(toolbar)
  }

  // MARK: Internal

  static let frameAutosaveName = "\(SettingsWindowController.self)Frame"

  private(set) var panes = [Pane]()
  private(set) var selectedPaneIndex = 0
  private(set) var detailViewController = SettingsDetailViewController()
  private(set) var sidebarViewController: SettingsSidebarViewController?

  var canGoBack: Bool {
    !backStack.isEmpty
  }

  var canGoForward: Bool {
    !forwardStack.isEmpty
  }

  func selectPane(at index: Int, recordingHistory: Bool = true) {
    guard panes.indices.contains(index) else { return }
    if recordingHistory, index != selectedPaneIndex {
      backStack.append(selectedPaneIndex)
      forwardStack.removeAll()
    }
    selectedPaneIndex = index
    showSelectedPane()
  }

  @objc
  func goBack(_: Any?) {
    guard let index = backStack.popLast() else { return }
    forwardStack.append(selectedPaneIndex)
    selectedPaneIndex = index
    showSelectedPane()
  }

  @objc
  func goForward(_: Any?) {
    guard let index = forwardStack.popLast() else { return }
    backStack.append(selectedPaneIndex)
    selectedPaneIndex = index
    showSelectedPane()
  }

  // MARK: Private

  @Shared(.isSettingsWindowFloating) private var isSettingsWindowFloating = false
  @Shared(.settingsWindowLastTabIndex) private var storedSelectedTabIndex = 0
  private var isSettingsWindowFloatingCancellable: AnyCancellable?
  private var backStack = [Int]()
  private var forwardStack = [Int]()
  private weak var navigationItem: NSToolbarItemGroup?

  private func rebuildContent() {
    guard let window else { return }

    // Assigning a content view controller resizes the window to fit it; keep the current frame.
    let frame = window.frame
    detailViewController = SettingsDetailViewController()

    if panes.count > 1 {
      let sidebar = SettingsSidebarViewController(panes: panes) { [weak self] index in
        self?.selectPane(at: index)
      }
      sidebarViewController = sidebar

      let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebar)
      sidebarItem.canCollapse = false
      sidebarItem.minimumThickness = 180
      sidebarItem.maximumThickness = 280

      let detailItem = NSSplitViewItem(viewController: detailViewController)
      detailItem.titlebarSeparatorStyle = .automatic

      let splitViewController = NSSplitViewController()
      splitViewController.splitViewItems = [sidebarItem, detailItem]
      splitViewController.splitView.autosaveName = "\(Self.frameAutosaveName)SplitView"
      contentViewController = splitViewController

      let toolbar = NSToolbar(identifier: "\(Self.self)Toolbar")
      toolbar.delegate = self
      toolbar.displayMode = .iconOnly
      toolbar.allowsUserCustomization = false
      window.toolbar = toolbar
      window.styleMask.insert(.fullSizeContentView)
      window.initialFirstResponder = sidebar.tableView
    } else {
      sidebarViewController = nil
      contentViewController = detailViewController
      window.toolbar = nil
      window.styleMask.remove(.fullSizeContentView)
    }

    window.setFrame(frame, display: false)
  }

  private func showSelectedPane() {
    let pane = panes[selectedPaneIndex]
    detailViewController.show(pane)
    sidebarViewController?.select(selectedPaneIndex)

    if panes.count > 1 {
      window?.title = pane.label
      $storedSelectedTabIndex.withLock { $0 = selectedPaneIndex }
    } else {
      window?.title = "\(Bundle.main.appName) Settings"
    }
    updateNavigationItem()
  }

  private func updateNavigationItem() {
    guard let navigationItem, navigationItem.subitems.count == 2 else { return }
    navigationItem.subitems[0].isEnabled = canGoBack
    navigationItem.subitems[1].isEnabled = canGoForward
  }

  @objc
  private func navigate(_ sender: NSToolbarItemGroup) {
    switch sender.selectedIndex {
    case 0: goBack(sender)
    case 1: goForward(sender)
    default: break
    }
  }

  private func assertUniqueLabels(_ panes: [Pane]) {
    assert(panes.count == Set(panes.map(\.label)).count, "each pane needs to have a unique label")
    assert(panes.count == Set(panes.map(\.identifier)).count, "each pane needs to have a unique identifier")
  }

}

extension NSToolbarItem.Identifier {
  fileprivate static let settingsNavigation = Self("RBSettingsKit.navigation")
}
