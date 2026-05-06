import RBKit
import SwiftUI

struct AppPickerDemo: View {
  var body: some View {
    Section("App Picker") {
      HStack(alignment: .firstTextBaseline) {
        AppPicker(bundleID: $selectedBundleID)
        if let selectedBundleID {
          Text(selectedBundleID)
            .font(.system(.body, design: .monospaced))
            .textSelection(.enabled)
        }
      }
    }
  }

  @State private var selectedBundleID: AppPickerItem.ID?

}
