import Foundation

// https://nilcoalescing.com/blog/GetURLsForSystemFolders
// https://blog.eidinger.info/use-new-url-related-apis-from-ios-16-in-lower-versions
// https://alejandromp.com/blog/backport-swiftui-modifiers

extension URL {
  public var backport: Backport<Self> { Backport(self) }
}

@available(macOS, obsoleted: 13.0, message: "")
extension Backport where Content == URL? {
  public init?(filePath: String, isDirectory: Bool, relativeTo base: URL? = nil) {
    if #available(macOS 13.0, *) {
      self = Backport(URL(filePath: filePath, directoryHint: isDirectory ? .isDirectory : .notDirectory, relativeTo: base))
    } else {
      self = Backport(URL(fileURLWithPath: filePath, isDirectory: isDirectory))
    }
  }
}

@available(macOS, obsoleted: 13.0, message: "")
extension Backport where Content == URL {
  public func appending(component: String, directoryHint: URL._DirectoryHint = .inferFromPath) -> Backport<URL> {
    if #available(macOS 13.0, *) {
      return Backport(content.appending(component: component, directoryHint: directoryHint.directoryHint()))
    } else {
      return Backport(content.appendingPathComponent(component, isDirectory: directoryHint == .isDirectory))
    }
  }

  public func appending(queryItems: [URLQueryItem]) -> Backport<URL> {
    if #available(macOS 13.0, *) {
      return Backport(content.appending(queryItems: queryItems))
    } else {
      return Backport(content._appending(queryItems: queryItems))
    }
  }
}


extension URL {

  // MARK: Public

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
