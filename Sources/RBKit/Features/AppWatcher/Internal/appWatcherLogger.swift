import AppKit
import os

private let appWatcherLogger = Logger(
  subsystem: Bundle.main.bundleIdentifier ?? "",
  category: "app watcher",
)

func debugLog(_ message: String) {
  guard UserDefaults.standard.bool(forKey: "_AppWatcherLoggingEnabled") else { return }
  appWatcherLogger.log("\(message, privacy: .public)")
}

// MARK: - Event

enum Event: CustomStringConvertible {
  case launched
  case terminated(Bool)
  case activationPolicy(NSApplication.ActivationPolicy)
  case isFinishedLaunching(Bool)
  case isHidden(Bool)
  case activated
  case deactivated
  case applicationOwnedMenuBar
  case applicationDisownedMenuBar
  case skippingXPC(String)
  case skippingZombie

  // MARK: Internal

  var description: String {
    switch self {
    case .launched:
      "launched"
    case .terminated(let bool):
      "terminated \(bool)"
    case .activationPolicy(let activationPolicy):
      "activation policy \(activationPolicy)"
    case .isFinishedLaunching(let bool):
      "is finished launching \(bool)"
    case .isHidden(let bool):
      "is hidden \(bool)"
    case .activated:
      "activated"
    case .deactivated:
      "deactivated"
    case .applicationOwnedMenuBar:
      "application owned menu bar"
    case .applicationDisownedMenuBar:
      "application disowned menu bar"
    case .skippingXPC(let nsFileType):
      "skipping XPC (nsFileType: \(nsFileType))"
    case .skippingZombie:
      "skipping zombie"
    }
  }
}

func debugLog(event: Event, app: NSRunningApplication?) {
  debugLog("\(event): \(app?.bundleIdentifier ?? "UNKNOWN APP")")
}
