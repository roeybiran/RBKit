import AppKit

extension FileManager.DirectoryEnumerator {
  open class Mock: FileManager.DirectoryEnumerator {

    // MARK: Lifecycle

    public init(files: [Any] = []) {
      self.files = files
    }

    // MARK: Open

    open override var allObjects: [Any] { files }

    open override func nextObject() -> Any? {
      guard index < files.count else { return nil }
      defer { index += 1 }
      return files[index]
    }

    // MARK: Public

    public var files: [Any]
    public var index = 0

  }
}
