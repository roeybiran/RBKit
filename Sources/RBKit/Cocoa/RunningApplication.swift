import Foundation
import AppKit.NSRunningApplication

// MARK: - TargetApp

public struct RunningApplication: Equatable, Sendable {
  public let isTerminated: Bool
  public let isFinishedLaunching: Bool
  public let isHidden: Bool
  public let isActive: Bool
  public let ownsMenuBar: Bool
  public let activationPolicy: NSApplication.ActivationPolicy
  public let localizedName: String?
  public let bundleIdentifier: String?
  public let bundleURL: URL?
  public let executableURL: URL?
  public let processIdentifier: pid_t
  public let launchDate: Date?
  // public let icon: Data?
  public let executableArchitecture: Int

  public init(
    isTerminated: Bool,
    isFinishedLaunching: Bool,
    isHidden: Bool,
    isActive: Bool,
    ownsMenuBar: Bool,
    activationPolicy: NSApplication.ActivationPolicy,
    localizedName: String? = nil,
    bundleIdentifier: String? = nil,
    bundleURL: URL? = nil,
    executableURL: URL? = nil,
    processIdentifier: pid_t,
    launchDate: Date? = nil,
    // icon: Data? = nil,
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
    // self.icon = icon
    self.executableArchitecture = executableArchitecture
  }
}

extension RunningApplication {
  public init(runningApplication app: NSRunningApplication) {
    self.init(
      isTerminated: app.isTerminated,
      isFinishedLaunching: app.isFinishedLaunching,
      isHidden: app.isHidden,
      isActive: app.isActive,
      ownsMenuBar: app.ownsMenuBar,
      activationPolicy: app.activationPolicy,
      localizedName: app.localizedName,
      bundleIdentifier: app.bundleIdentifier,
      bundleURL: app.bundleURL,
      executableURL: app.executableURL,
      processIdentifier: app.processIdentifier,
      launchDate: app.launchDate,
      // icon: app.icon,
      executableArchitecture: app.executableArchitecture
    )
  }
}
