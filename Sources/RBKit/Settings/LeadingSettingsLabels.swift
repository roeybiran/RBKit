import SwiftUI

public struct LeadingSettingsLabels: View {
  let title: String
  let subtitle: String?

  public init(title: String, subtitle: String?) {
    self.title = title
    self.subtitle = subtitle
  }

  public var body: some View {
    VStack(alignment: .leading) {
      Text(title)
      if let subtitle {
        Text(subtitle)
          .foregroundColor(.secondary)
          .font(.system(size: NSFont.smallSystemFontSize))
      }
    }
  }
}

struct LeadingSettingsLabels_Previews: PreviewProvider {
    static var previews: some View {
      LeadingSettingsLabels(title: "Hello", subtitle: "Foobar")
    }
}
