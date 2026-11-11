import ComposableArchitecture
import RBKit
import SwiftUI

// MARK: - HotKeyRecorderView

public struct HotKeyRecorderView: View {

  // MARK: Lifecycle

  public init(configuration: HotKeyConfiguration) {
    title = configuration.title
    _store = State(
      initialValue: Store(
        initialState: HotKeyRecorder.State(
          id: configuration.id,
          ignoresWarnings: configuration.ignoreWarnings,
        )
      ) {
        HotKeyRecorder()
      }
    )
  }

  // MARK: Public

  public var body: some View {
    @Bindable var store = store
    LabeledContent(title) {
      HStack {
        if let issue = store.issue {
          Image(systemName: issue.symbolName)
            .foregroundStyle(issue.color)
            .help(issue.text)
            .accessibilityLabel(issue.text)
        }
        Text(store.recordedHotKeyLabel)
          .foregroundStyle(store.hotKey == nil ? .secondary : .primary)
        ControlGroup {
          Button {
            store.send(.editButtonClicked)
          } label: {
            Image(systemName: "square.and.pencil")
          }
          .accessibilityLabel("Edit shortcut")
          Button(role: .destructive) {
            store.send(.deleteButtonClicked)
          } label: {
            Image(systemName: "trash")
          }
          .accessibilityLabel("Delete shortcut")
          .disabled(store.isDeleteButtonDisabled)
        }
      }
    }
    .sheet(isPresented: $store.isEditorPresented.sending(\.isEditorPresentedChanged)) {
      SimpleDialog(isConfirmDisabled: store.isSaveButtonDisabled) {
        Section {
          HStack {
            ControlGroup("Modifiers") {
              Toggle("⌃", isOn: $store.isDraftControlModifierEnabled)
              Toggle("⌥", isOn: $store.isDraftOptionModifierEnabled)
              Toggle("⇧", isOn: $store.isDraftShiftModifierEnabled)
              Toggle("⌘", isOn: $store.isDraftCommandModifierEnabled)
            }
            Picker("Key", selection: $store.draftKey.sending(\.onSelectKey)) {
              Text(String.DEFAULT_RECORD_BUTTON_TEXT)
                .tag(nil as Key?)
              ForEach(Key.allCases) { key in
                Text(key.label(.long))
                  .tag(key as Key?)
              }
            }.labelsHidden()
          }.frame(maxWidth: .infinity, alignment: .center)
        } header: {
          Text(title).font(.headline).frame(maxWidth: .infinity, alignment: .center)
        }
      } onCancel: {
        store.send(.cancelButtonClicked)
      } onConfirm: {
        store.send(.saveButtonClicked)
      }
      .popover(item: $store.saveValidationPopover, arrowEdge: .bottom) { popover in
        Text(popover.message).padding()
      }
    }
    .task {
      store.send(.onAppear)
    }
  }

  // MARK: Private

  /// This view builds its own store from configuration, so @State preserves
  /// the store identity and in-progress edits across parent re-renders.
  @State private var store: StoreOf<HotKeyRecorder>

  private let title: String

}

#Preview {
  withDependencies { d in
    d.hotKeyManagerClient.start = { }
    d.hotKeyManagerClient.status = { id in
      switch id {
      case 1:
        .registered(.init(key: .a, modifiers: [.command]))
      default:
        nil
      }
    }
    d.symbolicHotKeysClient.copySymbolicHotKeys = { (nil, 0) }
  } operation: {
    Form {
      List {
        HotKeyRecorderView(configuration: .init(id: 1, title: "Activate"))
        HotKeyRecorderView(configuration: .init(id: 2, title: "Search"))
      }
    }
    .padding()
  }
}
