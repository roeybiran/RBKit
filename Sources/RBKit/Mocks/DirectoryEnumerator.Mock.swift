import AppKit

extension FileManager.DirectoryEnumerator {
  open class Mock: FileManager.DirectoryEnumerator {
    public var files: [Any]
    public var index = 0

    public init(files: [Any] = []) {
      self.files = files
    }

    open override func nextObject() -> Any? {
      guard index < files.count else { return nil }
      defer { index += 1 }
      return files[index]
    }

    open override var allObjects: [Any] { files }
  }
}
