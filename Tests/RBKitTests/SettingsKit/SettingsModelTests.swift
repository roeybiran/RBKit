import Testing
@testable import RBKit

@MainActor
struct SettingsModelTests {

  // MARK: Internal

  @Test
  func `select(_:), should record history, and goBack/goForward should walk it`() {
    let model = makeModel(paneCount: 3)

    #expect(!model.canGoBack)
    model.select(2)
    model.select(identifier: "pane-1")
    #expect(model.selectedIndex == 1)

    model.goBack()
    #expect(model.selectedIndex == 2)
    #expect(model.canGoForward)
    model.goBack()
    #expect(model.selectedIndex == 0)
    #expect(!model.canGoBack)
    model.goForward()
    #expect(model.selectedIndex == 2)

    model.select(0)
    #expect(!model.canGoForward)
  }

  @Test
  func `select(_:), with the current pane or recordingHistory false, should not record history`() {
    let model = makeModel(paneCount: 2)

    model.select(0)
    model.select(1, recordingHistory: false)
    #expect(model.selectedIndex == 1)
    #expect(!model.canGoBack)
  }

  @Test
  func `select(_:), with an invalid index or identifier, should keep the selection`() {
    let model = makeModel(paneCount: 2)
    model.select(1)

    model.select(5)
    model.select(identifier: "missing")
    #expect(model.selectedIndex == 1)
  }

  @Test
  func `setPanes(_:), should clamp the selection and clear history`() {
    let model = makeModel(paneCount: 3)
    model.select(2)

    model.setPanes([makeTestPane("Only", identifier: "only")])
    #expect(model.selectedIndex == 0)
    #expect(model.selectedPane?.identifier == "only")
    #expect(!model.canGoBack)
  }

  @Test
  func `onSelectionChange, should be called for every selection change`() {
    let model = makeModel(paneCount: 2)
    var count = 0
    model.onSelectionChange = { count += 1 }

    model.select(1)
    model.goBack()
    model.goForward()
    model.setPanes(model.panes)
    #expect(count == 4)
  }

  // MARK: Private

  private func makeModel(paneCount: Int) -> SettingsModel {
    let model = SettingsModel()
    model.setPanes((0..<paneCount).map { makeTestPane("Pane \($0)", identifier: "pane-\($0)") })
    return model
  }
}
