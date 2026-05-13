import Carbon

public final class RunLoopSourceMock: Sendable {

  // MARK: Lifecycle

  public init(id: String) {
    self.id = id
  }

  // MARK: Public

  public let id: String
}
