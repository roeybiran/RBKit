import Foundation

// https://nilcoalescing.com/blog/GetURLsForSystemFolders
// https://blog.eidinger.info/use-new-url-related-apis-from-ios-16-in-lower-versions
// https://alejandromp.com/blog/backport-swiftui-modifiers

extension URL {
  @available(macOS, introduced: 10.10, obsoleted: 13.0, message: "")
  public init(filePath path: String, directoryHint: URL._DirectoryHint = .inferFromPath, relativeTo base: URL? = nil) {
    if #available(macOS 13.0, *) {
      self = URL(filePath: path, directoryHint: directoryHint.directoryHint(), relativeTo: base)
    } else {
      self = URL(fileURLWithPath: path, isDirectory: directoryHint == .isDirectory)
    }
  }

  @available(macOS, introduced: 10.10, obsoleted: 13.0, message: "")
  public func appending(component: some StringProtocol, directoryHint: URL._DirectoryHint = .inferFromPath) -> URL {
    if #available(macOS 13.0, *) {
      appending(component: component, directoryHint: directoryHint.directoryHint())
    } else {
      appendingPathComponent(String(component), isDirectory: directoryHint == .isDirectory)
    }
  }

  @available(macOS, introduced: 10.10, obsoleted: 13.0, message: "")
  public mutating func append(component: some StringProtocol, directoryHint: URL._DirectoryHint = .inferFromPath) {
    if #available(macOS 13.0, *) {
      append(component: component, directoryHint: directoryHint.directoryHint())
    } else {
      appendPathComponent(String(component), isDirectory: directoryHint == .isDirectory)
    }
  }

  @available(macOS, introduced: 10.10, obsoleted: 13.0, message: "")
  public func appending_(queryItems: [URLQueryItem]) -> URL {
    if #available(macOS 13.0, *) {
      appending(queryItems: queryItems)
    } else {
      _appending(queryItems: queryItems)
    }
  }

  public func host_(percentEncoded: Bool = true) -> String? {
    if #available(macOS 13.0, *) {
      host(percentEncoded: percentEncoded)
    } else {
      URLComponents(url: self, resolvingAgainstBaseURL: false)?.host
    }
  }

  public enum _DirectoryHint {
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

  // MARK: Internal

  func _appending(queryItems: [URLQueryItem]) -> URL {
    var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
    let queryItems = (components?.queryItems ?? []) + queryItems
    components?.queryItems = queryItems
    guard let url = components?.url else { return self }
    return url
  }
}

