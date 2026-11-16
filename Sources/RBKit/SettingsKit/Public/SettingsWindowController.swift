import AppKit
import Combine
import Sharing
import SwiftUI

// MARK: - SettingsWindowController

/// A master-detail settings window, built with `NavigationSplitView`: a sidebar listing the
/// panes, and the selected pane's grouped `Form` in the detail column, with back/forward
/// navigation in the toolbar.
///
/// With a single pane, the sidebar and toolbar are omitted.
///
/// This controller only hosts the SwiftUI interface, so apps built on the AppKit lifecycle can
/// show the window and open a pane programmatically.
open class SettingsWindowController: NSWindowController {

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
    assert(!model.panes.isEmpty, "you must provide at least one pane")

    guard let window else { return }
    window.autorecalculatesKeyViewLoop = true

    let minimumSize = Self.minimumContentSize
    let hostingController = NSHostingController(
      rootView: SettingsView(model: model)
        .frame(minWidth: minimumSize.width, minHeight: minimumSize.height)
    )
    hostingController.sizingOptions = [.minSize]
    hostingController.sceneBridgingOptions = [.toolbars]
    contentViewController = hostingController

    let autosaveName = Self.frameAutosaveName
    if !window.setFrameUsingName(autosaveName) {
      window.setContentSize(Self.defaultContentSize)
      window.center()
    }
    windowFrameAutosaveName = autosaveName

    model.onSelectionChange = { [weak self] in
      self?.selectionDidChange()
    }
    let storedIndex = storedSelectedTabIndex
    model.select(model.panes.indices.contains(storedIndex) ? storedIndex : 0, recordingHistory: false)

    isSettingsWindowFloatingCancellable = $isSettingsWindowFloating.publisher
      .sink { [weak self] isSettingsWindowFloating in
        self?.window?.level = isSettingsWindowFloating ? .floating : .normal
      }
  }

  public func setPanes(_ panes: [Pane]) {
    assert(!panes.isEmpty, "you must provide at least one pane")
    assert(panes.count == Set(panes.map(\.label)).count, "each pane needs to have a unique label")
    assert(panes.count == Set(panes.map(\.identifier)).count, "each pane needs to have a unique identifier")
    model.setPanes(panes)
  }

  public override func doCommand(by selector: Selector) {
    if selector == #selector(NSSavePanel.cancel(_:)) {
      close()
    } else {
      super.doCommand(by: selector)
    }
  }

  public func openPane(identifier: String) {
    _ = window
    model.select(identifier: identifier)
  }

  // MARK: Internal

  static let frameAutosaveName = "\(SettingsWindowController.self)Frame"

  let model = SettingsModel()

  @objc
  func goBack(_: Any?) {
    model.goBack()
  }

  @objc
  func goForward(_: Any?) {
    model.goForward()
  }

  // MARK: Private

  @Shared(.isSettingsWindowFloating) private var isSettingsWindowFloating = false
  @Shared(.settingsWindowLastTabIndex) private var storedSelectedTabIndex = 0
  private var isSettingsWindowFloatingCancellable: AnyCancellable?

  private func selectionDidChange() {
    if model.panes.count > 1, let pane = model.selectedPane {
      window?.title = pane.label
      $storedSelectedTabIndex.withLock { $0 = model.selectedIndex }
    } else {
      window?.title = "\(Bundle.main.appName) Settings"
    }
  }

}
