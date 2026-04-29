import ApplicationServices

open class UIElementValueMock: Hashable {

  // MARK: Lifecycle

  public init(type: AXValueType = .axError, id: String = "") {
    self.type = type
    self.id = id
  }

  // MARK: Public

  public let type: AXValueType
  public let id: String

  public static func ==(lhs: UIElementValueMock, rhs: UIElementValueMock) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
