import Foundation

#if DEBUG
extension RunningApplication {
  public static func safari(
    bundleIdentifier: String = "com.apple.Safari",
    localizedName: String = "Safari",
    processIdentifier: pid_t = 0)
    -> Self
  {
    RunningApplication(
      isTerminated: false,
      isFinishedLaunching: true,
      isHidden: false,
      isActive: true,
      ownsMenuBar: true,
      activationPolicy: .regular,
      localizedName: localizedName,
      bundleIdentifier: bundleIdentifier,
      bundleURL: URL(fileURLWithPath: "/Applications/Safari.app"),
      executableURL: URL(fileURLWithPath: "/Applications/Safari.app/Contents/MacOS/Safari"),
      processIdentifier: processIdentifier,
      launchDate: .now,
      executableArchitecture: 0)
  }
}
#endif
