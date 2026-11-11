import Foundation

public struct InputSource: Hashable, Identifiable, CustomStringConvertible, Sendable {

  // MARK: Public

  public let id: String
  public let name: String

  public var description: String {
    name
  }

}
