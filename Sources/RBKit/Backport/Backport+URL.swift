import Foundation

extension URL {
  public var backport: Backport<Self> { Backport(self) }
}

// https://nilcoalescing.com/blog/GetURLsForSystemFolders/
// https://blog.eidinger.info/use-new-url-related-apis-from-ios-16-in-lower-versions

extension Backport where Content == URL? {
  public init?(filePath: String, isDirectory: Bool, relativeTo base: URL? = nil) {
    if #available(macOS 13.0, *) {
      self = Backport(URL(filePath: filePath, directoryHint: isDirectory ? .isDirectory : .notDirectory, relativeTo: base))
    } else {
      self = Backport(URL(fileURLWithPath: filePath, isDirectory: isDirectory))
    }
  }
}

extension Backport where Content == URL {
  public func appendingPathComponent(_ pathComponent: String, isDirectory: Bool) -> Backport<URL> {
    if #available(macOS 13.0, *) {
      return Backport(content.appending(path: pathComponent, directoryHint: isDirectory ? .isDirectory : .notDirectory))
    } else {
      return Backport(content.appendingPathComponent(pathComponent, isDirectory: isDirectory))
    }
  }
}
