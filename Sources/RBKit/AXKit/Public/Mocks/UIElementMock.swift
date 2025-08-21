import Quartz

open class UIElementMock: Hashable {
  public let id: String
  public var cgWindowID: CGWindowID
  public var title: String?
  public var isMinimized: Bool
  public var role: String?
  public var subrole: String?
  public var frame: CGRect?
  public var closeButton: UIElementMock?
  public var attributes = [String: Any]()

  public init(
    id: String = "", 
    cgWindowID: CGWindowID = 0,
    title: String? = nil,
    isMinimized: Bool = false,
    role: String? = nil,
    subrole: String? = nil,
    frame: CGRect? = nil,
    closeButton: UIElementMock? = nil
  ) {
    self.id = id
    self.cgWindowID = cgWindowID
    self.title = title
    self.isMinimized = isMinimized
    self.role = role
    self.subrole = subrole
    self.frame = frame
    self.closeButton = closeButton
  }
  
  public static func == (lhs: UIElementMock, rhs: UIElementMock) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
