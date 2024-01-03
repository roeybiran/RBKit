import Foundation
import AppKit.NSRunningApplication

public protocol RunningApplicationProtocol: Equatable, Sendable {
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

  init(app: NSRunningApplication)
}

extension RunningApplicationProtocol {
  public init(app: NSRunningApplication) {
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
      executableArchitecture: app.executableArchitecture
    )
  }
}
