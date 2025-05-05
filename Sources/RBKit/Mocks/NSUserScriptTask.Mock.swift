import Foundation

extension NSUserScriptTask {
  open class Mock: NSUserScriptTask {
    public var _execute: () async throws -> Void = { }
    public var _init: (_ url: URL) throws -> Void = { _ in }

    override init(url: URL) throws {
      try _init(url)
      try super.init(url: url)
    }

    open override func execute() async throws {
      try await _execute()
    }
  }
}
