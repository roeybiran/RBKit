import RBKit

public struct HotKeyConfiguration: Identifiable, Equatable {
  public init(id: HotKey.ID, title: String, ignoreWarnings: Bool = false) {
    self.id = id
    self.ignoreWarnings = ignoreWarnings
    self.title = title
  }

  public let id: HotKey.ID
  public let ignoreWarnings: Bool
  public let title: String
}
