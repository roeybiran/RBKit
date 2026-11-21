import SwiftUI

public struct SimpleSheet<Content: View>: View {

  // MARK: Lifecycle

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  // MARK: Public

  public var body: some View {
    content
      .padding()
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Close") {
            dismiss()
          }
          .keyboardShortcut(.defaultAction)
        }
      }
      .frame(height: 270)
  }

  // MARK: Internal

  @Environment(\.dismiss) var dismiss

  let content: Content

}

#Preview {
  SimpleSheet {
    Text("foo")
  }
}
