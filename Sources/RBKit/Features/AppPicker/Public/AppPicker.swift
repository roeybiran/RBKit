import Foundation
import SwiftUI

// MARK: - AppPicker

@available(macOS, deprecated: 15.0, message: "Use Picker initializers with currentValueLabel.")
public struct AppPicker: View {

  // MARK: Lifecycle

  public init(bundleID: Binding<AppPickerItem.ID?>) {
    _bundleID = bundleID
  }

  // MARK: Public

  @Binding public var bundleID: AppPickerItem.ID?

  public var body: some View {
    Picker(
      selection: Binding<Selection>(
        get: {
          if let bundleID {
            .app(bundleID)
          } else {
            .none
          }
        },
        set: { selection in
          switch selection {
          case .none:
            bundleID = nil

          case .app(let bundleID):
            self.bundleID = bundleID

          case .other:
            isPickerPresented = true
          }
        },
      )
    ) {
      Text("None")
        .tag(Selection.none)

      Divider()

      ForEach(standardAppsByBundleID.values.sorted(by: \.title)) { app in
        HStack {
          Image(nsImage: app.image)
            .resizable()
            .frame(width: 16, height: 16)
          Text(app.title)
        }
        .tag(Selection.app(app.id))
      }

      Divider()

      if let bundleID, standardAppsByBundleID[bundleID] == nil {
        let app = AppPickerItem(bundleID: bundleID)
        HStack {
          Image(nsImage: app.image)
            .resizable()
            .frame(width: 16, height: 16)
          Text(app.title)
        }
        .tag(Selection.app(app.id))

        Divider()
      }

      Text("Other...")
        .tag(Selection.other)
    } label: {
      Text("App")
    }
    .labelsHidden()
    .appImporter(
      isPresented: $isPickerPresented,
      onCompletion: { result in
        switch result {
        case .success(let items):
          guard let first = items.first else { return }
          bundleID = first.bundleID

        case .failure:
          break
        }
      },
    )
    .dropDestination(for: URL.self) { urls, _ in
      guard
        let url = urls.first(where: { Bundle(url: $0)?.bundleIdentifier != nil }),
        let bundleID = Bundle(url: url)?.bundleIdentifier
      else { return false }

      self.bundleID = bundleID
      return true
    }
  }

  // MARK: Private

  private enum Selection: Hashable {
    case none
    case app(AppPickerItem.ID)
    case other
  }

  @State private var isPickerPresented = false

  private let standardAppsByBundleID: [AppPickerItem.ID: AppPickerItem] = {
    let locations = FileManager.default.urls(
      for: .applicationDirectory,
      in: [.systemDomainMask, .localDomainMask],
    )
    let urls = locations.compactMap {
      try? FileManager.default.contentsOfDirectory(
        at: $0,
        includingPropertiesForKeys: nil,
      )
    }.flatMap { $0 }
    return urls.reduce(into: [AppPickerItem.ID: AppPickerItem]()) { result, url in
      guard let bundleID = Bundle(url: url)?.bundleIdentifier else { return }
      if result[bundleID] == nil {
        result[bundleID] = AppPickerItem(bundleID: bundleID)
      }
    }
  }()

}

#Preview {
  VStack {
    AppPicker(bundleID: .constant("com.apple.finder"))
    AppPicker(bundleID: .constant(nil))
  }
  .padding()
}
