import Dependencies
import Foundation
import os

let logger = Logger()

// MARK: - FrecencyStore

struct FrecencyStore<Key: FrecencyID>: Sendable {

  // MARK: Internal

  @Dependency(\.diskClient) var diskClient

  var url: URL?

  private(set) var items = FrecencyCollection<Key>()

  static func defaultURL() -> URL? {
    @Dependency(\.bundleClient) var bundleClient
    @Dependency(\.urlClient) var urlClient
    @Dependency(\.fileManagerClient) var fileManagerClient

    let applicationSupportDirectory = urlClient.applicationSupportDirectory()

    guard let selfBundleId = bundleClient.bundleIdentifier(bundle: bundleClient.main()) else {
      logger.log("Failed to get self bundle identifier")
      return nil
    }

    let parentDir = applicationSupportDirectory.appending(
      component: selfBundleId, directoryHint: .isDirectory
    )

    do {
      try fileManagerClient.createDirectory(
        atURL: parentDir, withIntermediateDirectories: true, attributes: nil
      )
    } catch {
      logger.log("Failed to create the application support directory, error: \(error)")
      return nil
    }

    return parentDir.appending(component: "recents", directoryHint: .notDirectory)
      .appendingPathExtension("json")
  }

  mutating func load() throws {
    guard let url else { return }
    let data = try diskClient.read(sourceURL: url)
    items = try decoder.decode(FrecencyCollection<Key>.self, from: data)
  }

  func save() throws {
    guard let url else { return }
    let data = try encoder.encode(items)
    try diskClient.write(data: data, destinationURL: url, options: [])
  }

  mutating func add(_ value: Key, query: String? = nil, timestamp: Date = .now) {
    items.add(entry: value, query: query, timestamp: timestamp)
  }

  func score(for item: Key) -> Double {
    items.score(for: item)
  }

  // MARK: Private

  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()

}
