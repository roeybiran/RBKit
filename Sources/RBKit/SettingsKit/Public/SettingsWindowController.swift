import AppKit
import Combine
import Dependencies
import Sharing

open class SettingsWindowController: NSWindowController {

  // MARK: Lifecycle

  public convenience init() {
    self.init(windowNibName: "")
  }

  public convenience init(_ panes: [Pane]) {
    self.init()
    setPanes(panes)
  }

  deinit {
    selectedTabViewItemTask?.cancel()
  }

  // MARK: Public

  override public func loadWindow() {
    window = NSWindow()
  }

  public override func windowDidLoad() {
    assert(!tabViewItems.isEmpty, "you must provide at least one tab view item")
    assert(tabViewItems.map(\.label).count == Set(tabViewItems.map(\.label)).count, "each pane needs to have a unique label")

    let tabViewController = NSTabViewController()
    tabViewController.tabViewItems = tabViewItems
    tabViewController.tabStyle = tabViewItems.count > 1 ? .toolbar : .unspecified

    windowFrameAutosaveName = "\(Self.self)"
    window?.autorecalculatesKeyViewLoop = true
    window?.styleMask = [.titled, .closable]
    contentViewController = tabViewController

    let idx = storedSelectedTabIndex < tabViewController.tabViewItems.count ? storedSelectedTabIndex : 0
    tabViewController.selectedTabViewItemIndex = idx

    isSettingsWindowFloatingCancellable = $isSettingsWindowFloating.publisher
      .sink { [weak self] isSettingsWindowFloating in
        self?.window?.level = isSettingsWindowFloating ? .floating : .normal
      }

    selectedTabViewItemTask?.cancel()
    selectedTabViewItemTask = Task { [weak self] in
      for await _ in keyValueChangeStream(
        observed: tabViewController,
        keyPath: \.selectedTabViewItemIndex,
        options: [.initial, .new],
      ) {
        guard let self else { return }
        guard let window else { continue }
        let tabView = tabViewController.tabView

        let defaultTitle = "\(Bundle.main.appName) Settings"
        let windowTitle: String
        if tabView.numberOfTabViewItems == 1 {
          windowTitle = defaultTitle
        } else {
          let tabViewItem = tabView.selectedTabViewItem
          $storedSelectedTabIndex.withLock {
            $0 = tabViewController.selectedTabViewItemIndex
          }
          windowTitle = tabViewItem?.label ?? defaultTitle
        }
        window.title = windowTitle

        let fittingSize = tabViewController.view.fittingSize
        let currentFrame = window.frame
        let newFrame = window.frameRect(forContentRect: NSRect(origin: .zero, size: fittingSize))
        let heightDiff = newFrame.height - currentFrame.height

        var currentFrameCopy = currentFrame

        currentFrameCopy.origin.y -= heightDiff
        currentFrameCopy.size.height += heightDiff

        window.setFrame(currentFrameCopy, display: true, animate: true)
      }
    }

    #if DEBUG
    if UserDefaults.standard.bool(forKey: "_isSettingsWindowResizable") {
      window?.styleMask.insert(.resizable)
    }
    #endif
  }

  public func setPanes(_ panes: [Pane]) {
    let items = panes.map(NSTabViewItem.init)
    assert(!items.isEmpty, "you must provide at least one tab view item")
    assert(items.map(\.label).count == Set(items.map(\.label)).count, "each pane needs to have a unique label")

    tabViewItems = items

    guard let tabViewController = contentViewController as? NSTabViewController else { return }

    tabViewController.tabViewItems = items
    tabViewController.tabStyle = items.count > 1 ? .toolbar : .unspecified
    if tabViewController.selectedTabViewItemIndex >= items.count {
      tabViewController.selectedTabViewItemIndex = 0
    }
  }

  public override func doCommand(by selector: Selector) {
    if selector == #selector(NSSavePanel.cancel(_:)) {
      close()
    } else {
      super.doCommand(by: selector)
    }
  }

  public func openPane(identifier: String) {
    guard let tabVC = contentViewController as? NSTabViewController else { return }
    tabVC.tabView.selectTabViewItem(withIdentifier: identifier)
  }

  // MARK: Internal

  var tabViewItems = [NSTabViewItem]()

  // MARK: Private

  @Shared(.isSettingsWindowFloating) private var isSettingsWindowFloating = false
  @Shared(.settingsWindowLastTabIndex) private var storedSelectedTabIndex = 0
  private var isSettingsWindowFloatingCancellable: AnyCancellable?
  private var selectedTabViewItemTask: Task<Void, Never>?

}
