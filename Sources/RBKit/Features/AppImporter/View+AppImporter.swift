import SwiftUI
import UniformTypeIdentifiers

extension View {
  public func appImporter(
    isPresented: Binding<Bool>,
    allowsMultipleSelection: Bool = false,
    onCompletion: @escaping (Result<[AppImporterItem], any Error>) -> Void,
  ) -> some View {
    fileImporter(
      isPresented: isPresented,
      allowedContentTypes: [.applicationBundle],
      allowsMultipleSelection: allowsMultipleSelection,
    ) { result in
      onCompletion(result.map { $0.compactMap(AppImporterItem.init) })
    }
    .fileDialogDefaultDirectory(.applicationDirectory)
  }
}
