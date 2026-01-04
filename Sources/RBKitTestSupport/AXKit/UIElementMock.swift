import Quartz

open class UIElementMock: Hashable {
  public let id: String
  public var attributes = [String: Any?]()

  public init(
    id: String = "", 
    attributes: [String: Any] = [:]
  ) {
    self.id = id
    self.attributes = attributes
  }

  public static func == (lhs: UIElementMock, rhs: UIElementMock) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

