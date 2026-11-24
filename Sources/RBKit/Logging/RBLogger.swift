import Foundation
import os

/// The logger every RBKit module uses.
///
/// All messages go to the `com.roeybiran.RBKit` subsystem, with the feature's name as the category.
/// Errors are always logged through `os`. Chatty tracing goes through ``verbose(_:)``, which is off unless
/// the category is listed in the `RBKitVerboseLogging` user default:
///
/// ```sh
/// defaults write <bundle-id> RBKitVerboseLogging -array AppWatcher OutlineViewDiffable
/// ```
package struct RBLogger: Sendable {

  // MARK: Lifecycle

  package init(_ category: String) {
    self.category = category
    os = Logger(subsystem: Self.subsystem, category: category)
  }

  // MARK: Package

  package static let subsystem = "com.roeybiran.RBKit"
  package static let verboseLoggingDefaultsKey = "RBKitVerboseLogging"

  package let category: String
  package let os: Logger

  package var isVerboseEnabled: Bool {
    UserDefaults.standard.stringArray(forKey: Self.verboseLoggingDefaultsKey)?.contains(category) == true
  }

  /// Logs at debug level, only when this category is enabled in `RBKitVerboseLogging`.
  package func verbose(_ message: @autoclosure () -> String) {
    guard isVerboseEnabled else { return }
    let message = message()
    os.debug("\(message, privacy: .public)")
  }
}
