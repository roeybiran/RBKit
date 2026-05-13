import Quartz

public final class UIElementMock: Hashable, Sendable {

  // MARK: Lifecycle

  public init(
    id: String = "",
    attributes: [String: (any Sendable)?] = [:],
  ) {
    self.id = id
    self.attributes = attributes
  }

  // MARK: Public

  public let id: String
  public let attributes: [String: (any Sendable)?]

  public static func ==(lhs: UIElementMock, rhs: UIElementMock) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
