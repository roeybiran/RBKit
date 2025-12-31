import Dependencies
import DependenciesMacros
import Foundation

// MARK: - URLClient

@DependencyClient
public struct URLClient: Sendable {
  public var resolvingSymlinksInPath: @Sendable (_ url: URL) -> URL = { $0 }
  public var resourceValues:
    @Sendable (_ url: URL, _ keys: Set<URLResourceKey>) throws -> URLResourceValuesWrapper = {
      _, _ in .init()
    }

  public var applicationSupportDirectory: @Sendable () -> URL = { .init(filePath: "/") }
  public var resolvingBookmarkData: @Sendable (
    _ bookmarkData: Data,
    _ options: URL.BookmarkResolutionOptions,
    _ relativeTo: URL?
  ) throws -> (url: URL, isStale: Bool) = { _, _, _ in throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError) }
}

// MARK: DependencyKey

extension URLClient: DependencyKey {
  public static let liveValue = Self(
    resolvingSymlinksInPath: {
      $0.resolvingSymlinksInPath()
    },
    resourceValues: { url, keys in
      .init(try url.resourceValues(forKeys: keys))
    },
    applicationSupportDirectory: {
      URL.applicationSupportDirectory
    },
    resolvingBookmarkData: { bookmarkData, options, relativeTo in
      var isStale = false
      let url = try URL(
        resolvingBookmarkData: bookmarkData,
        options: options,
        relativeTo: relativeTo,
        bookmarkDataIsStale: &isStale
      )
      return (url: url, isStale: isStale)
    }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var urlClient: URLClient {
    get { self[URLClient.self] }
    set { self[URLClient.self] = newValue }
  }
}
