import AppKit
import ComposableArchitecture
import RBKit
import SwiftUI

@Reducer
struct HotKeyRecorder {
  @ObservableState
  struct State: Equatable {

    struct Issue: Equatable {
      enum Kind: Equatable {
        case error
        case warning
      }

      let kind: Kind
      let text: String

      var symbolName: String {
        switch kind {
        case .error:
          "xmark.octagon.fill"
        case .warning:
          "exclamationmark.triangle.fill"
        }
      }

      var color: Color {
        switch kind {
        case .error:
          .red
        case .warning:
          .yellow
        }
      }
    }

    struct SaveValidationPopover: Equatable, Identifiable {
      let message: String

      var id: String {
        message
      }
    }

    let id: HotKey.ID
    var ignoresWarnings = false
    var isEditorPresented = false
    var hotKey: HotKey?
    var submittedHotKey: HotKey? = nil
    var issue: Issue?
    var draftKey: Key?
    var draftModifiers: NSEvent.ModifierFlags = []
    var saveValidationPopover: SaveValidationPopover?

    var isDraftCommandModifierEnabled: Bool {
      get { draftModifiers.contains(.command) }
      set {
        if newValue {
          draftModifiers.insert(.command)
        } else {
          draftModifiers.remove(.command)
        }
      }
    }

    var isDraftControlModifierEnabled: Bool {
      get { draftModifiers.contains(.control) }
      set {
        if newValue {
          draftModifiers.insert(.control)
        } else {
          draftModifiers.remove(.control)
        }
      }
    }

    var isDraftOptionModifierEnabled: Bool {
      get { draftModifiers.contains(.option) }
      set {
        if newValue {
          draftModifiers.insert(.option)
        } else {
          draftModifiers.remove(.option)
        }
      }
    }

    var isDraftShiftModifierEnabled: Bool {
      get { draftModifiers.contains(.shift) }
      set {
        if newValue {
          draftModifiers.insert(.shift)
        } else {
          draftModifiers.remove(.shift)
        }
      }
    }

    var keyPickerLabel: String {
      draftKey?.label(.long) ?? String.DEFAULT_RECORD_BUTTON_TEXT
    }

    var recordedHotKeyLabel: String {
      guard let hotKey else { return String.DEFAULT_RECORD_BUTTON_TEXT }
      return "\(hotKey.modifiers.modifierFlags.contains(.control) ? "⌃" : "")\(hotKey.modifiers.modifierFlags.contains(.option) ? "⌥" : "")\(hotKey.modifiers.modifierFlags.contains(.shift) ? "⇧" : "")\(hotKey.modifiers.modifierFlags.contains(.command) ? "⌘" : "")\(hotKey.key.label(.short))"
    }

    var isDraftDirty: Bool {
      draftKey != submittedHotKey?.key || draftModifiers != (submittedHotKey?.modifiers.modifierFlags ?? [])
    }

    var isDeleteButtonDisabled: Bool {
      hotKey == nil
    }

    var isSaveButtonDisabled: Bool {
      !isDraftDirty
    }

    var draftHotKey: HotKey? {
      guard let draftKey else { return nil }
      return HotKey(key: draftKey, modifiers: Modifiers(cocoa: draftModifiers))
    }

    var isDraftValid: Bool {
      guard let draftKey else { return false }
      if draftKey.isFunctionKey {
        return true
      }
      return !draftModifiers.subtracting(.shift).isEmpty
    }
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case onAppear
    case onStatusResponse(HotKeyStatus?)
    case onSelectKey(Key?)
    case isEditorPresentedChanged(Bool)
    case editButtonClicked
    case cancelButtonClicked
    case deleteButtonClicked
    case saveButtonClicked
    case onRegistrationResponse(HotKey, HotKeyStatus?)
  }

  @Dependency(\.hotKeyManagerClient) var hotKeyManagerClient
  @Dependency(\.symbolicHotKeysClient) var symbolicHotKeysClient

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action -> Effect<Action> in
      switch action {
      case .binding:
        if state.issue?.kind == .warning {
          state.issue = nil
        }
        state.saveValidationPopover = nil
        return .none

      case .onSelectKey(let key):
        state.draftKey = key
        if state.issue?.kind == .warning {
          state.issue = nil
        }
        state.saveValidationPopover = nil
        return .none

      case .editButtonClicked:
        state.isEditorPresented = true
        state.submittedHotKey = state.hotKey
        state.draftKey = state.hotKey?.key
        state.draftModifiers = state.hotKey?.modifiers.modifierFlags ?? []
        state.saveValidationPopover = nil
        return .none

      case .isEditorPresentedChanged(let isPresented):
        guard !isPresented else {
          state.isEditorPresented = true
          return .none
        }
        fallthrough

      case .cancelButtonClicked:
        state.isEditorPresented = false
        state.submittedHotKey = state.hotKey
        state.draftKey = state.hotKey?.key
        state.draftModifiers = state.hotKey?.modifiers.modifierFlags ?? []
        state.saveValidationPopover = nil
        if state.issue?.kind == .error {
          return .none
        }
        if
          let hotKey = state.hotKey,
          !state.ignoresWarnings,
          symbolicHotKeysClient.isConflicting(
            key: hotKey.key,
            modifiers: hotKey.modifiers,
          )
        {
          state.issue = .init(
            kind: .warning,
            text: "System shortcuts may take precedence over this shortcut.",
          )
        } else {
          state.issue = nil
        }
        return .none

      case .onAppear:
        let id = state.id
        return .run { send in
          await hotKeyManagerClient.start()
          await send(.onStatusResponse(await hotKeyManagerClient.status(id)))
        }

      case .onStatusResponse(let status):
        guard let status else {
          state.hotKey = nil
          state.submittedHotKey = nil
          state.draftKey = nil
          state.draftModifiers = []
          state.issue = nil
          state.saveValidationPopover = nil
          return .none
        }
        switch status {
        case .registered(let hotKey)
          where !state.ignoresWarnings && symbolicHotKeysClient.isConflicting(key: hotKey.key, modifiers: hotKey.modifiers):
          state.hotKey = hotKey
          state.submittedHotKey = hotKey
          state.draftKey = hotKey.key
          state.draftModifiers = hotKey.modifiers.modifierFlags
          state.issue = .init(
            kind: .warning,
            text: "System shortcuts may take precedence over this shortcut.",
          )

        case .registered(let hotKey):
          state.hotKey = hotKey
          state.submittedHotKey = hotKey
          state.draftKey = hotKey.key
          state.draftModifiers = hotKey.modifiers.modifierFlags
          state.issue = nil

        case .failedToRegister(let hotKey, let error):
          state.hotKey = hotKey
          state.submittedHotKey = hotKey
          state.draftKey = hotKey.key
          state.draftModifiers = hotKey.modifiers.modifierFlags
          state.issue = .init(kind: .error, text: error.description)
        }
        state.saveValidationPopover = nil
        return .none

      case .deleteButtonClicked:
        state.isEditorPresented = false
        state.hotKey = nil
        state.submittedHotKey = nil
        state.draftKey = nil
        state.draftModifiers = []
        state.issue = nil
        state.saveValidationPopover = nil
        let id = state.id
        return .run { _ in
          await hotKeyManagerClient.unregister(id)
        }

      case .saveButtonClicked:
        guard state.isDraftDirty else {
          return .none
        }
        guard let hotKey = state.draftHotKey, state.isDraftValid else {
          state.saveValidationPopover = .init(
            message: "A valid shortcut requires a key and a modifier, or a function key. Shift may be used only in combination with another modifier."
          )
          return .none
        }
        let id = state.id
        state.submittedHotKey = hotKey
        state.issue = nil
        state.saveValidationPopover = nil
        return .run { send in
          await hotKeyManagerClient.register(hotKey, id)
          await send(.onRegistrationResponse(hotKey, await hotKeyManagerClient.status(id)))
        }

      case .onRegistrationResponse(let hotKey, let status):
        switch status {
        case .failedToRegister(_, let error)?:
          state.issue = .init(kind: .error, text: error.description)
          return .none

        case .registered(let registeredHotKey)?:
          state.isEditorPresented = false
          state.hotKey = registeredHotKey
          state.submittedHotKey = registeredHotKey
          state.draftKey = registeredHotKey.key
          state.draftModifiers = registeredHotKey.modifiers.modifierFlags
          if
            !state.ignoresWarnings,
            symbolicHotKeysClient.isConflicting(
              key: registeredHotKey.key,
              modifiers: registeredHotKey.modifiers,
            )
          {
            state.issue = .init(
              kind: .warning,
              text: "System shortcuts may take precedence over this shortcut.",
            )
          } else {
            state.issue = nil
          }
          state.saveValidationPopover = nil
          return .none

        case nil:
          state.isEditorPresented = false
          state.hotKey = hotKey
          state.submittedHotKey = hotKey
          state.draftKey = hotKey.key
          state.draftModifiers = hotKey.modifiers.modifierFlags
          if
            !state.ignoresWarnings,
            symbolicHotKeysClient.isConflicting(
              key: hotKey.key,
              modifiers: hotKey.modifiers,
            )
          {
            state.issue = .init(
              kind: .warning,
              text: "System shortcuts may take precedence over this shortcut.",
            )
          } else {
            state.issue = nil
          }
          state.saveValidationPopover = nil
          return .none
        }
      }
    }
  }
}
