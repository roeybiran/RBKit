import AppKit
import SwiftUI

public struct AppImporterItemLabel: View {
  public let item: AppImporterItem

  public var body: some View {
    HStack {
      Image(nsImage: item.image)
        .resizable()
      .frame(width: 16, height: 16)
      Text(item.title)
    }
  }

  public init(item: AppImporterItem) {
    self.item = item
  }
}
