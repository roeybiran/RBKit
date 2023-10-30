import SwiftUI

extension Form {
  @ViewBuilder
  public func settingsStyle() -> some View {
    if #available(macOS 13.0, *) {
      self.formStyle(.grouped)
    } else {
      self
    }
  }
}
