import SwiftUI

extension View {
  func withSmallSystemFont() -> some View {
    self.font(.system(size: NSFont.smallSystemFontSize))
  }
}
