import Foundation

public enum PathWatcherError: Error, Equatable {
  case streamCreationFailed
  case streamStartFailed
}
