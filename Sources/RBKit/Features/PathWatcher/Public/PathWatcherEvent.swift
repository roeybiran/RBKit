import Foundation

// MARK: - PathWatcherEvent

public struct PathWatcherEvent: Sendable, Identifiable {
  public typealias ID = FSEventStreamEventId

  public let path: String
  public let flag: Flag
  public let id: FSEventStreamEventId
}

// MARK: PathWatcherEvent.Flag

extension PathWatcherEvent {
  public struct Flag: OptionSet, Hashable, Sendable, CustomDebugStringConvertible {

    // MARK: Lifecycle

    public init(rawValue: FSEventStreamEventFlags) {
      self.rawValue = rawValue
    }

    public init(rawValue: Int) {
      self.rawValue = FSEventStreamEventFlags(truncatingIfNeeded: rawValue)
    }

    // MARK: Public

    public static let none = Self(rawValue: kFSEventStreamEventFlagNone)
    public static let mustScanSubDirs = Self(rawValue: kFSEventStreamEventFlagMustScanSubDirs)
    public static let userDropped = Self(rawValue: kFSEventStreamEventFlagUserDropped)
    public static let kernelDropped = Self(rawValue: kFSEventStreamEventFlagKernelDropped)
    public static let eventIdsWrapped = Self(rawValue: kFSEventStreamEventFlagEventIdsWrapped)
    public static let historyDone = Self(rawValue: kFSEventStreamEventFlagHistoryDone)
    public static let rootChanged = Self(rawValue: kFSEventStreamEventFlagRootChanged)
    public static let mount = Self(rawValue: kFSEventStreamEventFlagMount)
    public static let unmount = Self(rawValue: kFSEventStreamEventFlagUnmount)
    public static let itemCreated = Self(rawValue: kFSEventStreamEventFlagItemCreated)
    public static let itemRemoved = Self(rawValue: kFSEventStreamEventFlagItemRemoved)
    public static let itemInodeMetaMod = Self(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)
    public static let itemRenamed = Self(rawValue: kFSEventStreamEventFlagItemRenamed)
    public static let itemModified = Self(rawValue: kFSEventStreamEventFlagItemModified)
    public static let itemFinderInfoMod = Self(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)
    public static let itemChangeOwner = Self(rawValue: kFSEventStreamEventFlagItemChangeOwner)
    public static let itemXattrMod = Self(rawValue: kFSEventStreamEventFlagItemXattrMod)
    public static let itemIsFile = Self(rawValue: kFSEventStreamEventFlagItemIsFile)
    public static let itemIsDir = Self(rawValue: kFSEventStreamEventFlagItemIsDir)
    public static let itemIsSymlink = Self(rawValue: kFSEventStreamEventFlagItemIsSymlink)
    public static let ownEvent = Self(rawValue: kFSEventStreamEventFlagOwnEvent)
    public static let itemIsHardlink = Self(rawValue: kFSEventStreamEventFlagItemIsHardlink)
    public static let itemIsLastHardlink = Self(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)
    public static let itemCloned = Self(rawValue: kFSEventStreamEventFlagItemCloned)

    public let rawValue: FSEventStreamEventFlags

    public var debugDescription: String {
      [
        (Flag.none, "none"),
        (.mustScanSubDirs, "mustScanSubDirs"),
        (.userDropped, "userDropped"),
        (.kernelDropped, "kernelDropped"),
        (.eventIdsWrapped, "eventIdsWrapped"),
        (.historyDone, "historyDone"),
        (.rootChanged, "rootChanged"),
        (.mount, "mount"),
        (.unmount, "unmount"),
        (.itemCreated, "itemCreated"),
        (.itemRemoved, "itemRemoved"),
        (.itemInodeMetaMod, "itemInodeMetaMod"),
        (.itemRenamed, "itemRenamed"),
        (.itemModified, "itemModified"),
        (.itemFinderInfoMod, "itemFinderInfoMod"),
        (.itemChangeOwner, "itemChangeOwner"),
        (.itemXattrMod, "itemXattrMod"),
        (.itemIsFile, "itemIsFile"),
        (.itemIsDir, "itemIsDir"),
        (.itemIsSymlink, "itemIsSymlink"),
        (.ownEvent, "ownEvent"),
        (.itemIsHardlink, "itemIsHardlink"),
        (.itemIsLastHardlink, "itemIsLastHardlink"),
        (.itemCloned, "itemCloned"),
      ]
      .filter { contains($0.0) }
      .map { $0.1 }
      .joined(separator: ", ")
    }
  }

}

extension PathWatcherEvent.ID {
  public static let now = Self(kFSEventStreamEventIdSinceNow)
}
