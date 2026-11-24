import Dependencies
import Foundation

private let log = RBLogger("FrecencyKit")

extension URL {
  static var frecencyURL: URL {
    @Dependency(\.bundleClient) var bundleClient
    @Dependency(\.urlClient) var urlClient
    @Dependency(\.fileManagerClient) var fileManagerClient

    let applicationSupportDirectory = urlClient.applicationSupportDirectory()
    var parentDir = applicationSupportDirectory

    if let bundleID = bundleClient.bundleIdentifier(bundle: bundleClient.main()) {
      let bundleDir = applicationSupportDirectory.appending(
        component: bundleID,
        directoryHint: .isDirectory,
      )

      do {
        try fileManagerClient.createDirectory(
          atURL: bundleDir,
          withIntermediateDirectories: true,
          attributes: nil,
        )
        parentDir = bundleDir
      } catch {
        log.os.error(
          "Failed to create the application support directory, error: \(error.localizedDescription, privacy: .public)"
        )
      }
    } else {
      log.os.error("Failed to get self bundle identifier")
    }

    return parentDir.appending(component: "recents", directoryHint: .notDirectory)
      .appendingPathExtension("json")
  }
}
