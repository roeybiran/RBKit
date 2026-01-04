import ApplicationServices

open class UIElementValueMock: Hashable {
  public let type: AXValueType
  public let id: String

  public init(type: AXValueType = .axError, id: String = "") {
    self.type = type
    self.id = id
  }
  
  public static func == (lhs: UIElementValueMock, rhs: UIElementValueMock) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

