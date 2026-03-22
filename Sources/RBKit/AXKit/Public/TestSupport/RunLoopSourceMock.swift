open class RunLoopSourceMock: Hashable {

  // MARK: Lifecycle

  public init(id: String = "") {
    self.id = id
  }

  // MARK: Public

  public let id: String

  public static func ==(lhs: RunLoopSourceMock, rhs: RunLoopSourceMock) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
