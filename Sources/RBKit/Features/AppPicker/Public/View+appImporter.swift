import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
  public func appImporter(
    isPresented: Binding<Bool>,
    allowsMultipleSelection: Bool = false,
    onCompletion: @escaping (Result<[AppPickerItem], any Error>) -> Void,
  ) -> some View {
    fileImporter(
      isPresented: isPresented,
      allowedContentTypes: [.applicationBundle],
      allowsMultipleSelection: allowsMultipleSelection,
    ) { result in
      onCompletion(
        result.map { urls in
          urls.compactMap { url in
            guard let bundleID = Bundle(url: url)?.bundleIdentifier else { return nil }
            return AppPickerItem(bundleID: bundleID)
          }
        }
      )
    }
    .fileDialogDefaultDirectory(.applicationDirectory)
  }
}
