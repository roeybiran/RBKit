import Testing
@testable import RBKit

@MainActor
struct SettingsModelTests {

  // MARK: Internal

  @Test
  func `setPanes(_:), should select the first pane without recording history`() {
    let model = makeModel(paneCount: 3)

    #expect(model.selection == "pane-0")
    #expect(model.selectedPane?.label == "Pane 0")
    #expect(!model.canGoBack)
  }

  @Test
  func `selection, when changed, should record history that goBack and goForward walk`() {
    let model = makeModel(paneCount: 3)

    model.selection = "pane-2"
    model.selection = "pane-1"

    model.goBack()
    #expect(model.selection == "pane-2")
    #expect(model.canGoForward)
    model.goBack()
    #expect(model.selection == "pane-0")
    #expect(!model.canGoBack)
    model.goForward()
    #expect(model.selection == "pane-2")

    model.selection = "pane-0"
    #expect(!model.canGoForward)
  }

  @Test
  func `selection, when set to the same pane, should not record history`() {
    let model = makeModel(paneCount: 2)

    model.selection = "pane-0"
    #expect(!model.canGoBack)
  }

  @Test
  func `selection, when cleared, should let goBack return to the previous pane`() {
    let model = makeModel(paneCount: 2)

    model.selection = nil
    #expect(model.selectedPane == nil)
    model.goBack()
    #expect(model.selection == "pane-0")
  }

  @Test
  func `restoreSelection(_:), should not record history`() {
    let model = makeModel(paneCount: 2)

    model.restoreSelection("pane-1")
    #expect(model.selection == "pane-1")
    #expect(!model.canGoBack)
  }

  @Test
  func `setPanes(_:), should keep a selection that still exists and clear history`() {
    let model = makeModel(paneCount: 3)
    model.selection = "pane-2"

    model.setPanes(Array(model.panes.reversed()))
    #expect(model.selection == "pane-2")
    #expect(!model.canGoBack)

    model.setPanes([makeTestPane("Only", identifier: "only")])
    #expect(model.selection == "only")
  }

  @Test
  func `onSelectionChange, should be called for every selection change`() {
    let model = makeModel(paneCount: 2)
    var count = 0
    model.onSelectionChange = { count += 1 }

    model.selection = "pane-1"
    model.selection = "pane-1"
    model.goBack()
    model.goForward()
    #expect(count == 3)
  }

  // MARK: Private

  private func makeModel(paneCount: Int) -> SettingsModel {
    let model = SettingsModel()
    model.setPanes((0..<paneCount).map { makeTestPane("Pane \($0)", identifier: "pane-\($0)") })
    return model
  }
}
