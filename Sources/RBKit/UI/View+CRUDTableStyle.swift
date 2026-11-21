import SwiftUI

extension View {
  public func CRUDTableStyle(_ data: some Collection & Equatable, placeholder: String) -> some View {
    tableStyle(.bordered)
      .animation(.default, value: data)
      .overlay {
        if data.isEmpty {
          Group {
            Rectangle().fill(Color(.windowBackgroundColor)).border(Color(.separatorColor))
            Text(placeholder).foregroundStyle(Color(.placeholderTextColor))
          }
          .transition(.opacity.animation(.easeInOut(duration: 0.2)))
        }
      }
  }
}
