import Quartz

public final class UIElementMock: Hashable, Sendable {

  // MARK: Lifecycle

  public init(
    id: String = "",
    attributes: [String: Any?] = [:],
  ) {
    self.id = id
    self.attributes = attributes
  }

  // MARK: Public

  public let id: String
  public nonisolated(unsafe) var attributes: [String: Any?]

  public static func ==(lhs: UIElementMock, rhs: UIElementMock) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
