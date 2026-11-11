import SwiftUI

// MARK: - SimpleDialog

public struct SimpleDialog<Content: View>: View {

  // MARK: Lifecycle

  public init(
    isConfirmDisabled: Bool,
    @ViewBuilder content: @escaping () -> Content,
    onCancel: @escaping () -> Void,
    onConfirm: @escaping () -> Void,
  ) {
    self.isConfirmDisabled = isConfirmDisabled
    self.content = content
    self.onCancel = onCancel
    self.onConfirm = onConfirm
  }

  // MARK: Public

  public let isConfirmDisabled: Bool
  @ViewBuilder public let content: () -> Content
  public let onCancel: () -> Void
  public let onConfirm: () -> Void

  public var body: some View {
    Form {
      content()
    }
    .dialogToolbar(
      isConfirmDisabled: isConfirmDisabled,
      onCancel: onCancel,
      onConfirm: onConfirm,
    )
    .padding()
  }
}

// MARK: - Dialog Toolbar

extension View {
  public func dialogToolbar(
    isConfirmDisabled: Bool,
    onCancel: @escaping () -> Void,
    onConfirm: @escaping () -> Void,
  ) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          onCancel()
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("OK") {
          onConfirm()
        }
        .disabled(isConfirmDisabled)
      }
    }
  }
}
