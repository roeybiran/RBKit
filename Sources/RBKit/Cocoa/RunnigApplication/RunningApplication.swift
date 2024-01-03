import Foundation
import AppKit.NSRunningApplication

public struct RunningApplication: RunningApplicationProtocol {
  public var isTerminated: Bool
  public var isFinishedLaunching: Bool
  public var isHidden: Bool
  public var isActive: Bool
  public var ownsMenuBar: Bool
  public var activationPolicy: NSApplication.ActivationPolicy
  public let localizedName: String?
  public let bundleIdentifier: String?
  public let bundleURL: URL?
  public let executableURL: URL?
  public let processIdentifier: pid_t
  public let launchDate: Date?
  public let executableArchitecture: Int

  public init(
    isTerminated: Bool,
    isFinishedLaunching: Bool,
    isHidden: Bool,
    isActive: Bool,
    ownsMenuBar: Bool,
    activationPolicy: NSApplication.ActivationPolicy,
    localizedName: String?,
    bundleIdentifier: String?,
    bundleURL: URL?,
    executableURL: URL?,
    processIdentifier: pid_t,
    launchDate: Date?,
    executableArchitecture: Int
  ) {
    self.isTerminated = isTerminated
    self.isFinishedLaunching = isFinishedLaunching
    self.isHidden = isHidden
    self.isActive = isActive
    self.ownsMenuBar = ownsMenuBar
    self.activationPolicy = activationPolicy
    self.localizedName = localizedName
    self.bundleIdentifier = bundleIdentifier
    self.bundleURL = bundleURL
    self.executableURL = executableURL
    self.processIdentifier = processIdentifier
    self.launchDate = launchDate
    self.executableArchitecture = executableArchitecture
  }
}
