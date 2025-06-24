import Foundation

extension NSUserScriptTask {
  open class Mock: NSUserScriptTask {

    // MARK: Lifecycle

    override init(url: URL) throws {
      try _init(url)
      try super.init(url: url)
    }

    // MARK: Open

    open override func execute() async throws {
      try await _execute()
    }

    // MARK: Public

    public var _execute: () async throws -> Void = { }
    public var _init: (_ url: URL) throws -> Void = { _ in }

  }
}
