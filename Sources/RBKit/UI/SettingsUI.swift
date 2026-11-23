import SwiftUI

// https://marioaguzman.github.io/design/layoutguidelines/

// MARK: - View

extension View {
  public func settingsPadding() -> some View {
    padding(.bottom, 20)
      .padding(.horizontal, 20)
      .padding(.top, 14)
  }
}

// MARK: - SettingsDivider

public struct SettingsDivider: View {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var body: some View {
    Divider()
      .frame(height: 24)
  }
}

#Preview {
  Form {
    Text("Before")
    SettingsDivider()
    Text("After")
  }
}
