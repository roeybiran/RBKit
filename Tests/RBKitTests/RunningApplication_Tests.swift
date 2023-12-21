import XCTest
@testable import RBKit

final class RunningApplicationTests: XCTestCase {
  private class _App: NSRunningApplication {
    override var processIdentifier: pid_t { 0 }
    override var bundleIdentifier: String? { "com.foo.bar" }
    override var localizedName: String? { "Foo" }
    override var bundleURL: URL? { URL(fileURLWithPath: "file://apps/foo") }
  }

  // MARK: - TargetAppTests
  func test_targetApp_init() {
    let app = _App()
    let a = RunningApplication(runningApplication: app)
    let b = RunningApplication(
      isTerminated: app.isTerminated,
      isFinishedLaunching: app.isFinishedLaunching,
      isHidden: app.isHidden,
      isActive: app.isActive,
      ownsMenuBar: app.ownsMenuBar,
      activationPolicy: app.activationPolicy,
      processIdentifier: app.processIdentifier,
      executableArchitecture: app.executableArchitecture
    )
    XCTAssertEqual(a, b)
  }
}
