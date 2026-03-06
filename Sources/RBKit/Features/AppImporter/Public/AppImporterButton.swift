import AppKit
import SwiftUI

// MARK: - AppImporterButton

public struct AppImporterButton: View {

  // MARK: Lifecycle

  public init(bundleID: Binding<AppImporterItem.ID?>) {
    _bundleID = bundleID
  }

  // MARK: Public

  @Binding public var bundleID: AppImporterItem.ID?

  public var apps: [AppImporterItem] {
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
    let bundleIDs = urls.compactMap { Bundle(url: $0)?.bundleIdentifier }
    return bundleIDs.map(AppImporterItem.init(bundleID:)).sorted(by: \.title)
  }

  public var body: some View {
    AppImporterButtonRepresentable(
      bundleID: $bundleID,
      apps: apps,
      onOtherSelected: {
        isSheetPresented = true
      },
    )
    .appImporter(
      isPresented: $isSheetPresented,
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
  }

  // MARK: Private

  @State private var isSheetPresented = false

}

#Preview {
  VStack {
    AppImporterButton(bundleID: .constant("com.apple.finder"))
    AppImporterButton(bundleID: .constant(nil))
  }
  .padding()
}
