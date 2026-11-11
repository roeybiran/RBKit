import SwiftUI

public struct PickedAppLabel: View {

  // MARK: Lifecycle

  public init(_ titleKey: String, image: NSImage) {
    self.titleKey = titleKey
    self.image = image
  }

  public init(_ item: AppPickerItem) {
    self.init(item.title, image: item.image)
  }

  // MARK: Public

  public var body: some View {
    Label {
      Text(titleKey)
    } icon: {
      Image(nsImage: image)
        .resizable()
        .frame(width: 16, height: 16)
    }
  }

  // MARK: Internal

  let titleKey: String
  let image: NSImage
}
