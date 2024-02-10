import Foundation
import AppKit.NSRunningApplication

public protocol RunningApplicationProtocol: Equatable, Hashable {
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

#if DEBUG
extension RunningApplicationProtocol {
  public static func mock(
    isTerminated: Bool = false,
    isFinishedLaunching: Bool = true,
    isHidden: Bool = false,
    isActive: Bool = true,
    ownsMenuBar: Bool = true,
    activationPolicy: NSApplication.ActivationPolicy = .regular,
    localizedName: String = "Safari",
    bundleIdentifier: String = "com.apple.Safari",
    bundleURL: URL = URL(fileURLWithPath: "/Applications/Safari.app"),
    executableURL: URL = URL(fileURLWithPath: "/Applications/Safari.app/Contents/MacOS/Safari"),
    processIdentifier: pid_t = 0,
    launchDate: Date = .now,
    executableArchitecture: Int = 0
  )
  -> Self
  {
    Self(
      isTerminated: isTerminated,
      isFinishedLaunching: isFinishedLaunching,
      isHidden: isHidden,
      isActive: isActive,
      ownsMenuBar: ownsMenuBar,
      activationPolicy: activationPolicy,
      localizedName: localizedName,
      bundleIdentifier: bundleIdentifier,
      bundleURL: bundleURL,
      executableURL: executableURL,
      processIdentifier: processIdentifier,
      launchDate: launchDate,
      executableArchitecture: executableArchitecture
    )
  }
}

#endif

