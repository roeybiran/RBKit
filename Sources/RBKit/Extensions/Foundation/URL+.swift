import Foundation

// https://nilcoalescing.com/blog/GetURLsForSystemFolders
// https://blog.eidinger.info/use-new-url-related-apis-from-ios-16-in-lower-versions
// https://alejandromp.com/blog/backport-swiftui-modifiers

@available(macOS, deprecated: 13.0, message: "")
extension URL {

  // MARK: Public

  public enum BackportedDirectoryHint {
    case isDirectory
    case notDirectory
    case checkFileSystem
    case inferFromPath

    @available(macOS 13, *)
    func directoryHint() -> DirectoryHint {
      switch self {
      case .isDirectory: .isDirectory
      case .notDirectory: .notDirectory
      case .checkFileSystem: .checkFileSystem
      case .inferFromPath: .inferFromPath
      }
    }
  }

  public static func filePath(
    _ path: String, directoryHint: URL.BackportedDirectoryHint = .inferFromPath,
    relativeTo base: URL? = nil) -> Self
  {
    if #available(macOS 13.0, *) {
      return URL(filePath: path, directoryHint: directoryHint.directoryHint(), relativeTo: base)
    } else {
      return URL(fileURLWithPath: path, isDirectory: directoryHint == .isDirectory)
    }
  }

  public func backported_appending(
    component: some StringProtocol, directoryHint: URL.BackportedDirectoryHint = .inferFromPath)
    -> URL
  {
    if #available(macOS 13.0, *) {
      appending(component: component, directoryHint: directoryHint.directoryHint())
    } else {
      appendingPathComponent(String(component), isDirectory: directoryHint == .isDirectory)
    }
  }

  public mutating func backported_append(
    component: some StringProtocol, directoryHint: URL.BackportedDirectoryHint = .inferFromPath)
  {
    if #available(macOS 13.0, *) {
      append(component: component, directoryHint: directoryHint.directoryHint())
    } else {
      appendPathComponent(String(component), isDirectory: directoryHint == .isDirectory)
    }
  }

  public func backported_appending(queryItems: [URLQueryItem]) -> URL {
    if #available(macOS 13.0, *) {
      appending(queryItems: queryItems)
    } else {
      _appending(queryItems: queryItems)
    }
  }

  public func backported_host(percentEncoded: Bool = true) -> String? {
    if #available(macOS 13.0, *) {
      host(percentEncoded: percentEncoded)
    } else {
      URLComponents(url: self, resolvingAgainstBaseURL: false)?.host
    }
  }

  // MARK: Internal

  func _appending(queryItems: [URLQueryItem]) -> URL {
    var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
    let queryItems = (components?.queryItems ?? []) + queryItems
    components?.queryItems = queryItems
    guard let url = components?.url else { return self }
    return url
  }
}
