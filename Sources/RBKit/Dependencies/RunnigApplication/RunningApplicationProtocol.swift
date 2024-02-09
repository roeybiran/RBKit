import Foundation
import AppKit.NSRunningApplication

public protocol RunningApplicationProtocol: Equatable {
  var isTerminated: Bool { get set }
  var isFinishedLaunching: Bool { get set }
  var isHidden: Bool { get set }
  var isActive: Bool { get set }
  var ownsMenuBar: Bool { get set }
  var activationPolicy: NSApplication.ActivationPolicy { get set }
  var localizedName: String? { get }
  var bundleIdentifier: String? { get }
  var bundleURL: URL? { get }
  var executableURL: URL? { get }
  var processIdentifier: pid_t { get }
  var launchDate: Date? { get }
  // var icon: Data?
  var executableArchitecture: Int { get }

  init(
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
    // icon: Data? = nil,
    executableArchitecture: Int
  )
}

extension RunningApplicationProtocol {
  public init(nsRunningApplication: NSRunningApplication) {
    self.init(
      isTerminated: nsRunningApplication.isTerminated,
      isFinishedLaunching: nsRunningApplication.isFinishedLaunching,
      isHidden: nsRunningApplication.isHidden,
      isActive: nsRunningApplication.isActive,
      ownsMenuBar: nsRunningApplication.ownsMenuBar,
      activationPolicy: nsRunningApplication.activationPolicy,
      localizedName: nsRunningApplication.localizedName,
      bundleIdentifier: nsRunningApplication.bundleIdentifier,
      bundleURL: nsRunningApplication.bundleURL,
      executableURL: nsRunningApplication.executableURL,
      processIdentifier: nsRunningApplication.processIdentifier,
      launchDate: nsRunningApplication.launchDate,
      executableArchitecture: nsRunningApplication.executableArchitecture
    )
  }
}

