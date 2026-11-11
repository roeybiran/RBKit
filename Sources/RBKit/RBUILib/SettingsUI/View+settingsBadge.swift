import SwiftUI

extension View {
  public func settingsBadge(color: Color, isSelected: Bool) -> some View {
    let foregroundColor: Color = isSelected ? .primary : color
    let backgroundColor: Color = isSelected ? .accentColor : color.opacity(0.1)
    return padding(.horizontal, 8)
      .padding(.vertical, 2)
      .foregroundStyle(foregroundColor)
      .background(backgroundColor)
      .clipShape(Capsule())
  }
}
