import AppKit

public enum AppWatcherEvent: Hashable, Sendable {
  case launched([NSRunningApplication])
  case didFinishedLaunching(NSRunningApplication)
  case activated(NSRunningApplication)
  case deactivated(NSRunningApplication)
  case ownedMenuBar(NSRunningApplication)
  case disownedMenuBar(NSRunningApplication)
  case terminated(NSRunningApplication)
  case hidden(NSRunningApplication)
  case unhidden(NSRunningApplication)
  case activationPolicyChanged(NSRunningApplication)
}
