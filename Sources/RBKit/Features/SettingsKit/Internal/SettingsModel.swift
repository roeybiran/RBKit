import Observation

/// The settings window's panes, the selected pane, and the back/forward history.
@MainActor
@Observable
final class SettingsModel {

  // MARK: Internal

  private(set) var panes = [Pane]()

  /// Called after the selection changes.
  @ObservationIgnored var onSelectionChange: (() -> Void)?

  /// The selected pane, bound to the sidebar list. Changing it records history.
  var selection: Pane.ID? {
    didSet {
      guard selection != oldValue else { return }
      if !isTraversingHistory, let oldValue {
        backStack.append(oldValue)
        forwardStack.removeAll()
      }
      onSelectionChange?()
    }
  }

  var selectedPane: Pane? {
    panes.first { $0.id == selection }
  }

  var canGoBack: Bool {
    !backStack.isEmpty
  }

  var canGoForward: Bool {
    !forwardStack.isEmpty
  }

  /// Replaces the panes, keeping the selection if it still exists, and clears history.
  func setPanes(_ panes: [Pane]) {
    self.panes = panes
    backStack.removeAll()
    forwardStack.removeAll()
    if selectedPane == nil {
      restoreSelection(panes.first?.id)
    }
  }

  /// Selects a pane without recording history, e.g. when restoring a saved selection.
  func restoreSelection(_ id: Pane.ID?) {
    withoutRecordingHistory {
      selection = id
    }
  }

  func goBack() {
    guard let id = backStack.popLast() else { return }
    if let selection {
      forwardStack.append(selection)
    }
    withoutRecordingHistory {
      selection = id
    }
  }

  func goForward() {
    guard let id = forwardStack.popLast() else { return }
    if let selection {
      backStack.append(selection)
    }
    withoutRecordingHistory {
      selection = id
    }
  }

  // MARK: Private

  private var backStack = [Pane.ID]()
  private var forwardStack = [Pane.ID]()
  @ObservationIgnored private var isTraversingHistory = false

  private func withoutRecordingHistory(_ body: () -> Void) {
    isTraversingHistory = true
    body()
    isTraversingHistory = false
  }

}
