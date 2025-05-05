import SwiftUI

public struct FullWidthButton<Label: View>: View {
  let action: () -> Void
  let label: () -> Label
  let role: ButtonRole?

  public init(role: ButtonRole? = nil, action: @escaping () -> Void, label: @escaping () -> Label) {
    self.action = action
    self.label = label
    self.role = role
  }

  public var body: some View {
    Button(role: role, action: action) {
      label().frame(maxWidth: .infinity)
    }
  }
}
