import Observation

/// The settings window's panes, the selected pane, and the back/forward history.
@MainActor
@Observable
final class SettingsModel {

  // MARK: Internal

  private(set) var panes = [Pane]()
  private(set) var selectedIndex = 0

  /// Called after the selected pane changes, including when the panes are replaced.
  @ObservationIgnored var onSelectionChange: (() -> Void)?

  var selectedPane: Pane? {
    panes.indices.contains(selectedIndex) ? panes[selectedIndex] : nil
  }

  var canGoBack: Bool {
    !backStack.isEmpty
  }

  var canGoForward: Bool {
    !forwardStack.isEmpty
  }

  func setPanes(_ panes: [Pane]) {
    self.panes = panes
    backStack.removeAll()
    forwardStack.removeAll()
    if !panes.indices.contains(selectedIndex) {
      selectedIndex = 0
    }
    onSelectionChange?()
  }

  func select(_ index: Int, recordingHistory: Bool = true) {
    guard panes.indices.contains(index) else { return }
    if recordingHistory, index != selectedIndex {
      backStack.append(selectedIndex)
      forwardStack.removeAll()
    }
    selectedIndex = index
    onSelectionChange?()
  }

  func select(identifier: String) {
    guard let index = panes.firstIndex(where: { $0.identifier == identifier }) else { return }
    select(index)
  }

  func goBack() {
    guard let index = backStack.popLast() else { return }
    forwardStack.append(selectedIndex)
    selectedIndex = index
    onSelectionChange?()
  }

  func goForward() {
    guard let index = forwardStack.popLast() else { return }
    backStack.append(selectedIndex)
    selectedIndex = index
    onSelectionChange?()
  }

  // MARK: Private

  private var backStack = [Int]()
  private var forwardStack = [Int]()

}
