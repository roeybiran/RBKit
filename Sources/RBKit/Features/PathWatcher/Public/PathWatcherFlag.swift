import Foundation

// MARK: - PathWatcherFlag

public struct PathWatcherFlag: OptionSet, Sendable {

  // MARK: Lifecycle

  public init(rawValue: FSEventStreamCreateFlags) {
    self.rawValue = rawValue
  }

  init(_ value: Int) {
    rawValue = FSEventStreamCreateFlags(truncatingIfNeeded: value)
  }

  // MARK: Public

  public static let none = Self(kFSEventStreamCreateFlagNone)
  public static let useCFTypes = Self(kFSEventStreamCreateFlagUseCFTypes)
  public static let noDefer = Self(kFSEventStreamCreateFlagNoDefer)
  public static let watchRoot = Self(kFSEventStreamCreateFlagWatchRoot)
  public static let ignoreSelf = Self(kFSEventStreamCreateFlagIgnoreSelf)
  public static let fileEvents = Self(kFSEventStreamCreateFlagFileEvents)
  public static let markSelf = Self(kFSEventStreamCreateFlagMarkSelf)
  public static let useExtendedData = Self(kFSEventStreamCreateFlagUseExtendedData)
  public static let fullHistory = Self(kFSEventStreamCreateFlagFullHistory)

  public let rawValue: FSEventStreamCreateFlags

}
