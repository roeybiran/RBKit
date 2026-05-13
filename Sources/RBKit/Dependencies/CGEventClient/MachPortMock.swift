import Carbon

public final class MachPortMock: Sendable {

  // MARK: Lifecycle

  public init(id: String) {
    self.id = id
  }

  // MARK: Public

  public let id: String
}
