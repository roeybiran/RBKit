import Foundation

// MARK: - CrashReport

public struct CrashReport {
  public init(url: URL, date: Date, contents: String) {
    self.url = url
    self.date = date
    self.contents = contents
  }

  public let url: URL
  public let date: Date
  public let contents: String

}
