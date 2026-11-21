import SwiftUI

public struct SettingsTableContainer<
  Item: Identifiable,
  Items: Collection & Equatable,
  Content: View,
>: View where Items.Element == Item {

  // MARK: Lifecycle

  public init(
    items: Items,
    itemPluralName: String,
    systemImageName: String,
    onAdd: @escaping () -> Void,
    onRemove: @escaping () -> Void,
    isRemoveDisabled: Bool,
    onEdit: @escaping (Item.ID) -> Void,
    height: CGFloat = 200,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.items = items
    self.itemPluralName = itemPluralName
    self.systemImageName = systemImageName
    self.onAdd = onAdd
    self.onRemove = onRemove
    self.isRemoveDisabled = isRemoveDisabled
    self.onEdit = onEdit
    self.height = height
    self.content = content
  }

  // MARK: Public

  public let items: Items
  public let itemPluralName: String
  public let systemImageName: String
  @ViewBuilder public let content: () -> Content
  public let onAdd: () -> Void
  public let onRemove: () -> Void
  public let isRemoveDisabled: Bool
  public let onEdit: (Item.ID) -> Void
  public let height: CGFloat

  public var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      content()
        .opacity(items.isEmpty ? 0 : 1)
        .tableStyle(.bordered)
        .contextMenu(forSelectionType: Item.ID.self) { selection in
          if let selectedID = selection.first, selection.count == 1 {
            Button("Edit") {
              onEdit(selectedID)
            }
          }
        } primaryAction: { selection in
          if let selectedID = selection.first {
            onEdit(selectedID)
          }
        }
        .frame(height: height)
        .overlay {
          if items.isEmpty {
            ContentUnavailableView {
              Label {
                Text("No \(itemPluralName)")
              } icon: {
                Image(systemName: systemImageName)
              }
              .font(.body)
            }
          }
        }
        .border(Color(nsColor: .separatorColor), width: 1)
      ControlGroup {
        Button(action: onAdd) {
          Image(systemName: "plus")
        }
        Button(action: onRemove) {
          Image(systemName: "minus")
        }
        .disabled(isRemoveDisabled)
      }
      .buttonStyle(.borderless)
    }
    .animation(.default, value: items)
    .onDeleteCommand(perform: onRemove)
  }
}

#Preview {
  struct PreviewItem: Identifiable, Equatable {
    let id: String
  }

  return VStack {
    SettingsTableContainer(
      items: [PreviewItem(id: "")],
      itemPluralName: "Items",
      systemImageName: "tray",
      onAdd: { },
      onRemove: { },
      isRemoveDisabled: false,
      onEdit: { _ in },
      content: {
        Text("Hello")
      },
    )
    SettingsTableContainer(
      items: [PreviewItem](),
      itemPluralName: "Items",
      systemImageName: "tray",
      onAdd: { },
      onRemove: { },
      isRemoveDisabled: false,
      onEdit: { _ in },
      content: {
        Text("Hello")
          .frame(width: 400)
      },
    )
  }
}
