import AppKit
import Carbon
import ComposableArchitecture
import DependenciesTestSupport
import RBKit
import Testing
@testable import HotKeyRecorder

// MARK: - HotKeyRecorderTests

@Suite(
  .dependencies {
    $0.hotKeyManagerClient.start = { }
    $0.hotKeyManagerClient.register = { _, _ in }
    $0.hotKeyManagerClient.unregister = { _ in }
    $0.hotKeyManagerClient.status = { _ in nil }
    $0.symbolicHotKeysClient.copySymbolicHotKeys = { (nil, noErr) }
  }
)
@MainActor
struct HotKeyRecorderTests {
  @Test(
    .dependencies {
      let hotKey = HotKey(key: .a, modifiers: [.command])
      $0.hotKeyManagerClient.status = { _ in .registered(hotKey) }
    }
  )
  func `onAppear should load the current hot key into the draft`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(id: 1)
    ) {
      HotKeyRecorder()
    }

    await store.send(.onAppear)
    await store.receive(.onStatusResponse(.registered(hotKey))) {
      $0.hotKey = hotKey
      $0.submittedHotKey = hotKey
      $0.draftKey = hotKey.key
      $0.draftModifiers = hotKey.modifiers.modifierFlags
    }
  }

  @Test(
    .dependencies {
      let hotKey = HotKey(key: .a, modifiers: [.command])
      $0.hotKeyManagerClient.status = { _ in .failedToRegister(hotKey: hotKey, error: .userConflict) }
    }
  )
  func `onAppear with error should populate the error state and keep the hot key visible`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(id: 1)
    ) {
      HotKeyRecorder()
    }

    await store.send(.onAppear)
    await store.receive(.onStatusResponse(.failedToRegister(hotKey: hotKey, error: .userConflict))) {
      $0.hotKey = hotKey
      $0.submittedHotKey = hotKey
      $0.draftKey = hotKey.key
      $0.draftModifiers = hotKey.modifiers.modifierFlags
      $0.issue = .init(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one.")
    }
  }

  @Test(
    .dependencies {
      let hotKey = HotKey(key: .a, modifiers: [.command])
      $0.hotKeyManagerClient.status = { _ in .registered(hotKey) }
      $0.symbolicHotKeysClient.copySymbolicHotKeys = {
        (
          CFArray.mock(dicts: (key: hotKey.key.keyCode, mods: hotKey.modifiers.carbon, enabled: true)),
          noErr,
        )
      }
    }
  )
  func `onAppear should surface a system warning when the saved hot key conflicts with system prefs`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(id: 1)
    ) {
      HotKeyRecorder()
    }

    await store.send(.onAppear)
    await store.receive(.onStatusResponse(.registered(hotKey))) {
      $0.hotKey = hotKey
      $0.submittedHotKey = hotKey
      $0.issue = .init(kind: .warning, text: "System shortcuts may take precedence over this shortcut.")
      $0.draftKey = hotKey.key
      $0.draftModifiers = hotKey.modifiers.modifierFlags
    }
  }

  @Test(
    .dependencies {
      let hotKey = HotKey(key: .a, modifiers: [.command])
      $0.hotKeyManagerClient.status = { _ in .registered(hotKey) }
      $0.symbolicHotKeysClient.copySymbolicHotKeys = {
        (
          CFArray.mock(dicts: (key: hotKey.key.keyCode, mods: hotKey.modifiers.carbon, enabled: true)),
          noErr,
        )
      }
    }
  )
  func `onAppear should not assign a system warning when warnings are ignored`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(id: 1, ignoresWarnings: true)
    ) {
      HotKeyRecorder()
    }

    await store.send(.onAppear)
    await store.receive(.onStatusResponse(.registered(hotKey))) {
      $0.hotKey = hotKey
      $0.submittedHotKey = hotKey
      $0.draftKey = hotKey.key
      $0.draftModifiers = hotKey.modifiers.modifierFlags
    }
  }

  @Test
  func `onAppear with no saved hot key should clear stale state`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        hotKey: hotKey,
        issue: .init(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one."),
        draftKey: hotKey.key,
        draftModifiers: hotKey.modifiers.modifierFlags,
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.onAppear)
    await store.receive(.onStatusResponse(nil)) {
      $0.hotKey = nil
      $0.submittedHotKey = nil
      $0.issue = nil
      $0.draftKey = nil
      $0.draftModifiers = []
      $0.saveValidationPopover = nil
    }
  }

  @Test
  func `binding draft changes should not mutate the saved hot key`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        hotKey: hotKey,
        draftKey: hotKey.key,
        draftModifiers: hotKey.modifiers.modifierFlags,
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.binding(.set(\.draftKey, .b))) {
      $0.draftKey = .b
    }
    await store.send(.binding(.set(\.isDraftOptionModifierEnabled, true))) {
      $0.draftModifiers = [.command, .option]
    }

    #expect(store.state.hotKey == hotKey)
  }

  @Test
  func `binding should clear the validation popover and warning issue`() async {
    let store = TestStore(
      initialState: .mock(
        id: 1,
        issue: .init(kind: .warning, text: "System shortcuts may take precedence over this shortcut."),
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.binding(.set(\.isDraftCommandModifierEnabled, true))) {
      $0.issue = nil
      $0.draftModifiers = [.command]
      $0.saveValidationPopover = nil
    }
  }

  @Test
  func `binding, with error issue, should preserve the error and clear the validation popover`() async {
    let store = TestStore(
      initialState: .mock(
        id: 1,
        issue: .init(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one."),
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.binding(.set(\.isDraftCommandModifierEnabled, true))) {
      $0.draftModifiers = [.command]
      $0.saveValidationPopover = nil
    }
  }

  @Test
  func `onSelectKey should update the draft key and clear the validation popover`() async {
    let store = TestStore(
      initialState: .mock(
        id: 1,
        issue: .init(kind: .warning, text: "System shortcuts may take precedence over this shortcut."),
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.onSelectKey(.a)) {
      $0.draftKey = .a
      $0.issue = nil
      $0.saveValidationPopover = nil
    }
  }

  @Test
  func `onSelectKey with nil should clear the draft key and validation popover`() async {
    let store = TestStore(
      initialState: .mock(
        id: 1,
        draftKey: .a,
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.onSelectKey(nil)) {
      $0.draftKey = nil
      $0.saveValidationPopover = nil
    }
  }

  @Test
  func `onSelectKey, with error issue, should preserve the error and clear the validation popover`() async {
    let store = TestStore(
      initialState: .mock(
        id: 1,
        issue: .init(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one."),
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.onSelectKey(.a)) {
      $0.draftKey = .a
      $0.saveValidationPopover = nil
    }
  }

  @Test
  func `binding modifiers without a key should still make the draft dirty`() async {
    let store = TestStore(
      initialState: .mock(id: 1)
    ) {
      HotKeyRecorder()
    }

    await store.send(.binding(.set(\.isDraftCommandModifierEnabled, true))) {
      $0.draftModifiers = [.command]
    }

    #expect(store.state.isDraftDirty)
    #expect(!store.state.isSaveButtonDisabled)
  }

  @Test
  func `issue should reflect the current error`() {
    var state = HotKeyRecorder.State.mock(
      id: 1,
      issue: .init(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one."),
    )

    #expect(state.issue?.text == "The chosen keyboard shortcut conflicts with an existing one.")
    #expect(state.issue?.symbolName == "xmark.octagon.fill")
    state.issue = nil
    #expect(state.issue == nil)
  }

  @Test
  func `state presentation properties should reflect the selected key and current error`() {
    var state = HotKeyRecorder.State.mock(
      id: 1,
      issue: .init(kind: .error, text: "This keyboard shortcut is already in use by another application."),
    )

    #expect(state.issue?.text == "This keyboard shortcut is already in use by another application.")
    #expect(state.issue?.symbolName == "xmark.octagon.fill")
    #expect(state.keyPickerLabel == String.DEFAULT_RECORD_BUTTON_TEXT)
    #expect(state.recordedHotKeyLabel == String.DEFAULT_RECORD_BUTTON_TEXT)

    state.issue = .init(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one.")
    #expect(state.issue?.text == "The chosen keyboard shortcut conflicts with an existing one.")

    state.hotKey = .init(key: .a, modifiers: [.command])
    #expect(state.recordedHotKeyLabel == "⌘A")

    state.hotKey = .init(key: .backtick, modifiers: [.command])
    #expect(state.recordedHotKeyLabel == "⌘`")

    state.draftKey = .f1
    #expect(state.keyPickerLabel == "F1")
  }

  @Test
  func `label style should provide short and long labels`() {
    #expect(Key.backtick.label(.short) == "`")
    #expect(Key.backtick.label(.long) == "Backtick (`)")
    #expect(Key.slash.label(.short) == "/")
    #expect(Key.slash.label(.long) == "Slash (/)")
  }

  @Test
  func `state derived properties should reflect modifier toggles and issue styling`() {
    var state = HotKeyRecorder.State.mock(
      id: 1,
      issue: .init(kind: .warning, text: "System shortcuts may take precedence over this shortcut."),
    )

    #expect(state.issue?.text == "System shortcuts may take precedence over this shortcut.")
    #expect(state.issue?.symbolName == "exclamationmark.triangle.fill")
    #expect(state.issue?.color == .yellow)
    #expect(state.isDeleteButtonDisabled)
    #expect(state.isSaveButtonDisabled)

    state.draftKey = .a
    state.isDraftShiftModifierEnabled = true
    #expect(state.draftModifiers == [.shift])
    #expect(!state.isDraftValid)

    state.isDraftCommandModifierEnabled = true
    #expect(state.draftModifiers == [.command, .shift])
    #expect(state.isDraftValid)

    state.isDraftShiftModifierEnabled = false
    state.isDraftCommandModifierEnabled = false
    #expect(state.draftModifiers == [])
  }

  @Test
  func `state defaults and issue helpers should reflect default recorder behavior`() {
    let state = HotKeyRecorder.State(id: 1)
    let popover = HotKeyRecorder.State.SaveValidationPopover(message: "Invalid hot key")
    let issue = HotKeyRecorder.State.Issue(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one.")

    #expect(!state.ignoresWarnings)
    #expect(!state.isEditorPresented)
    #expect(state.draftModifiers == [])
    #expect(state.draftHotKey == nil)
    #expect(state.submittedHotKey == nil)
    #expect(!state.isDraftValid)
    #expect(popover.id == "Invalid hot key")
    #expect(issue.symbolName == "xmark.octagon.fill")
    #expect(issue.color == .red)
  }

  @Test
  func `control option and shift modifier accessors should round trip all branches`() {
    var state = HotKeyRecorder.State(id: 1)

    #expect(!state.isDraftControlModifierEnabled)
    state.isDraftControlModifierEnabled = true
    #expect(state.isDraftControlModifierEnabled)
    #expect(state.draftModifiers == [.control])
    state.isDraftControlModifierEnabled = false
    #expect(!state.isDraftControlModifierEnabled)
    #expect(state.draftModifiers == [])

    state.draftModifiers = [.option, .shift]
    #expect(state.isDraftOptionModifierEnabled)
    #expect(state.isDraftShiftModifierEnabled)
    state.isDraftOptionModifierEnabled = false
    #expect(!state.isDraftOptionModifierEnabled)
    #expect(state.isDraftShiftModifierEnabled)
    #expect(state.draftModifiers == [.shift])
  }

  @Test
  func `editButtonClicked should present the editor and reset the draft from the saved hot key`() async {
    let savedHotKey = HotKey(key: .a, modifiers: [.command])
    let unsavedHotKey = HotKey(key: .b, modifiers: [.option])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        hotKey: savedHotKey,
        submittedHotKey: unsavedHotKey,
        draftKey: unsavedHotKey.key,
        draftModifiers: unsavedHotKey.modifiers.modifierFlags,
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.editButtonClicked) {
      $0.isEditorPresented = true
      $0.submittedHotKey = savedHotKey
      $0.draftKey = savedHotKey.key
      $0.draftModifiers = savedHotKey.modifiers.modifierFlags
      $0.saveValidationPopover = nil
    }
  }

  @Test(
    .dependencies {
      let hotKey = HotKey(key: .a, modifiers: [.command])
      $0.symbolicHotKeysClient.copySymbolicHotKeys = {
        (
          CFArray.mock(dicts: (key: hotKey.key.keyCode, mods: hotKey.modifiers.carbon, enabled: true)),
          noErr,
        )
      }
    }
  )
  func `cancelButtonClicked should dismiss the editor and restore the saved hot key state`() async {
    let savedHotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        isEditorPresented: true,
        hotKey: savedHotKey,
        submittedHotKey: .init(key: .b, modifiers: [.option]),
        draftKey: .b,
        draftModifiers: [.option],
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.cancelButtonClicked) {
      $0.isEditorPresented = false
      $0.submittedHotKey = savedHotKey
      $0.draftKey = savedHotKey.key
      $0.draftModifiers = savedHotKey.modifiers.modifierFlags
      $0.issue = .init(kind: .warning, text: "System shortcuts may take precedence over this shortcut.")
    }
  }

  @Test
  func `saveButtonClicked with an invalid draft should show a validation popover`() async {
    nonisolated(unsafe) var didRegister = false

    let store = TestStore(
      initialState: .mock(
        id: 1,
        draftKey: .a,
      )
    ) {
      HotKeyRecorder()
    } withDependencies: {
      $0.hotKeyManagerClient.register = { _, _ in didRegister = true }
    }

    await store.send(.saveButtonClicked) {
      $0.saveValidationPopover = .init(
        message: "A valid shortcut requires a key and a modifier, or a function key. Shift may be used only in combination with another modifier."
      )
    }

    #expect(!didRegister)
  }

  @Test
  func `saveButtonClicked with a function key and no modifiers should save it`() async {
    let hotKey = HotKey(key: .f1, modifiers: [])
    nonisolated(unsafe) var registeredHotKey: HotKey?

    let store = TestStore(
      initialState: HotKeyRecorder.State.mock(
        id: 1,
        draftKey: .f1,
      )
    ) {
      HotKeyRecorder()
    } withDependencies: {
      $0.hotKeyManagerClient.register = { hotKey, _ in
        registeredHotKey = hotKey
      }
      $0.hotKeyManagerClient.status = { _ in .registered(hotKey) }
      $0.symbolicHotKeysClient.copySymbolicHotKeys = { (nil, noErr) }
    }

    await store.send(.saveButtonClicked) {
      $0.submittedHotKey = hotKey
    }
    await store.receive(.onRegistrationResponse(hotKey, .registered(hotKey))) {
      $0.hotKey = hotKey
      $0.submittedHotKey = hotKey
      $0.draftKey = hotKey.key
      $0.draftModifiers = hotKey.modifiers.modifierFlags
    }

    #expect(registeredHotKey == hotKey)
  }

  @Test
  func `saveButtonClicked, with successful conflicting registration, should surface a warning`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        draftKey: hotKey.key,
        draftModifiers: hotKey.modifiers.modifierFlags,
      )
    ) {
      HotKeyRecorder()
    } withDependencies: {
      $0.hotKeyManagerClient.register = { _, _ in }
      $0.hotKeyManagerClient.status = { _ in .registered(hotKey) }
      $0.symbolicHotKeysClient.copySymbolicHotKeys = {
        (
          CFArray.mock(dicts: (key: hotKey.key.keyCode, mods: hotKey.modifiers.carbon, enabled: true)),
          noErr,
        )
      }
    }

    await store.send(.saveButtonClicked) {
      $0.submittedHotKey = hotKey
    }
    await store.receive(.onRegistrationResponse(hotKey, .registered(hotKey))) {
      $0.hotKey = hotKey
      $0.submittedHotKey = hotKey
      $0.draftKey = hotKey.key
      $0.draftModifiers = hotKey.modifiers.modifierFlags
      $0.issue = .init(kind: .warning, text: "System shortcuts may take precedence over this shortcut.")
    }
  }

  @Test(
    .dependencies {
      $0.hotKeyManagerClient.status = { _ in nil }
    }
  )
  func `saveButtonClicked, with nil registration status, should still save the draft`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        draftKey: hotKey.key,
        draftModifiers: hotKey.modifiers.modifierFlags,
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.saveButtonClicked) {
      $0.submittedHotKey = hotKey
    }
    await store.receive(.onRegistrationResponse(hotKey, nil)) {
      $0.hotKey = hotKey
      $0.submittedHotKey = hotKey
      $0.draftKey = hotKey.key
      $0.draftModifiers = hotKey.modifiers.modifierFlags
    }
  }

  @Test
  func `saveButtonClicked with an empty clean draft should do nothing`() async {
    let store = TestStore(
      initialState: .mock(id: 1)
    ) {
      HotKeyRecorder()
    }

    await store.send(.saveButtonClicked)
  }

  @Test
  func `saveButtonClicked with a clean draft should do nothing`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        hotKey: hotKey,
        draftKey: hotKey.key,
        draftModifiers: hotKey.modifiers.modifierFlags,
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.saveButtonClicked)
  }

  @Test
  func `saveButtonClicked with a valid dirty draft should save it`() async {
    let hotKey = HotKey(key: .a, modifiers: [.command])
    nonisolated(unsafe) var registeredHotKey: HotKey?
    nonisolated(unsafe) var registeredID: HotKey.ID?

    let store = TestStore(
      initialState: .mock(
        id: 1,
        isEditorPresented: true,
        draftKey: .a,
        draftModifiers: [.command],
      )
    ) {
      HotKeyRecorder()
    } withDependencies: {
      $0.hotKeyManagerClient.register = {
        registeredHotKey = $0
        registeredID = $1
      }
      $0.hotKeyManagerClient.status = { _ in .registered(hotKey) }
      $0.symbolicHotKeysClient.copySymbolicHotKeys = { (nil, noErr) }
    }

    await store.send(.saveButtonClicked) {
      $0.submittedHotKey = hotKey
    }
    await store.receive(.onRegistrationResponse(hotKey, .registered(hotKey))) {
      $0.isEditorPresented = false
      $0.hotKey = hotKey
      $0.submittedHotKey = hotKey
      $0.draftKey = hotKey.key
      $0.draftModifiers = hotKey.modifiers.modifierFlags
    }

    #expect(registeredHotKey == hotKey)
    #expect(registeredID == 1)
  }

  @Test
  func `saveButtonClicked with a valid dirty draft should clear stale issues before saving`() async {
    let savedHotKey = HotKey(key: .b, modifiers: [.command])
    let draftHotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        hotKey: savedHotKey,
        issue: .init(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one."),
        draftKey: draftHotKey.key,
        draftModifiers: draftHotKey.modifiers.modifierFlags,
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    } withDependencies: {
      $0.hotKeyManagerClient.register = { _, _ in }
      $0.hotKeyManagerClient.status = { _ in .registered(draftHotKey) }
      $0.symbolicHotKeysClient.copySymbolicHotKeys = { (nil, noErr) }
    }

    await store.send(.saveButtonClicked) {
      $0.submittedHotKey = draftHotKey
      $0.issue = nil
      $0.saveValidationPopover = nil
    }
    await store.receive(.onRegistrationResponse(draftHotKey, .registered(draftHotKey))) {
      $0.hotKey = draftHotKey
      $0.submittedHotKey = draftHotKey
      $0.draftKey = draftHotKey.key
      $0.draftModifiers = draftHotKey.modifiers.modifierFlags
    }
  }

  @Test
  func `saveButtonClicked should surface a save error and disable save until the draft changes again`() async {
    let savedHotKey = HotKey(key: .b, modifiers: [.command])
    let draftHotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        hotKey: savedHotKey,
        draftKey: draftHotKey.key,
        draftModifiers: draftHotKey.modifiers.modifierFlags,
      )
    ) {
      HotKeyRecorder()
    } withDependencies: {
      $0.hotKeyManagerClient.register = { _, _ in }
      $0.hotKeyManagerClient.status = { _ in .failedToRegister(hotKey: draftHotKey, error: .userConflict) }
    }

    await store.send(.saveButtonClicked) {
      $0.submittedHotKey = draftHotKey
    }
    await store.receive(.onRegistrationResponse(draftHotKey, .failedToRegister(hotKey: draftHotKey, error: .userConflict))) {
      $0.issue = .init(kind: .error, text: "The chosen keyboard shortcut conflicts with an existing one.")
    }

    #expect(store.state.hotKey == savedHotKey)
    #expect(store.state.submittedHotKey == draftHotKey)
    #expect(store.state.draftHotKey == draftHotKey)
    #expect(store.state.issue?.text == "The chosen keyboard shortcut conflicts with an existing one.")
    #expect(!store.state.isDraftDirty)
    #expect(store.state.isSaveButtonDisabled)
  }

  @Test
  func `deleteButtonClicked should clear the hot key and draft`() async {
    nonisolated(unsafe) var unregisteredID: HotKey.ID?
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let store = TestStore(
      initialState: .mock(
        id: 1,
        isEditorPresented: true,
        hotKey: hotKey,
        draftKey: hotKey.key,
        draftModifiers: hotKey.modifiers.modifierFlags,
      )
    ) {
      HotKeyRecorder()
    } withDependencies: {
      $0.hotKeyManagerClient.unregister = { unregisteredID = $0 }
    }

    await store.send(.deleteButtonClicked) {
      $0.isEditorPresented = false
      $0.hotKey = nil
      $0.submittedHotKey = nil
      $0.draftKey = nil
      $0.draftModifiers = []
      $0.issue = nil
    }

    #expect(unregisteredID == 1)
  }

  @Test(
    .dependencies {
      $0.hotKeyManagerClient.unregister = { _ in }
    }
  )
  func `deleteButtonClicked should clear the validation popover`() async {
    let store = TestStore(
      initialState: .mock(
        id: 1,
        hotKey: .init(key: .a, modifiers: [.command]),
        draftKey: .a,
        draftModifiers: [.command],
        saveValidationPopover: .init(message: "Invalid hot key"),
      )
    ) {
      HotKeyRecorder()
    }

    await store.send(.deleteButtonClicked) {
      $0.hotKey = nil
      $0.submittedHotKey = nil
      $0.draftKey = nil
      $0.draftModifiers = []
      $0.saveValidationPopover = nil
    }
  }
}

// MARK: - HotKeyRecorder.State Mock

extension HotKeyRecorder.State {
  static func mock(
    id: HotKey.ID,
    ignoresWarnings: Bool = false,
    isEditorPresented: Bool = false,
    hotKey: HotKey? = nil,
    submittedHotKey: HotKey? = nil,
    issue: HotKeyRecorder.State.Issue? = nil,
    draftKey: Key? = nil,
    draftModifiers: NSEvent.ModifierFlags = [],
    saveValidationPopover: HotKeyRecorder.State.SaveValidationPopover? = nil,
  ) -> Self {
    Self(
      id: id,
      ignoresWarnings: ignoresWarnings,
      isEditorPresented: isEditorPresented,
      hotKey: hotKey,
      submittedHotKey: submittedHotKey ?? hotKey,
      issue: issue,
      draftKey: draftKey,
      draftModifiers: draftModifiers,
      saveValidationPopover: saveValidationPopover,
    )
  }
}

extension CFArray {
  static func mock(dicts: (key: Int, mods: Int, enabled: Bool)...) -> Unmanaged<CFArray> {
    let nsArray = NSArray(array: dicts.map {
      NSDictionary(dictionary: [
        kHISymbolicHotKeyEnabled: $0.enabled,
        kHISymbolicHotKeyCode: $0.key,
        kHISymbolicHotKeyModifiers: $0.mods,
      ])
    })
    return Unmanaged.passRetained(nsArray as CFArray)
  }
}
