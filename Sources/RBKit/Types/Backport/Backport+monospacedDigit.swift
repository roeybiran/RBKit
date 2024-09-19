import SwiftUI

extension Backport where Content: View {
  @ViewBuilder
  public func monospacedDigit() -> some View {
    if #available(macOS 12.0, *) {
      content.monospacedDigit()
    } else {
      content
    }
  }
}
