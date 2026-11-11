import Foundation
import os

private let outlineViewDiffableLogger = Logger(
  subsystem: "com.roeybiran.OutlineViewDiffable",
  category: "OutlineViewDiffable",
)

func outlineViewDiffableLogMessage(_ message: String) {
  let isLoggingEnabled = UserDefaults.standard.object(forKey: "_OutlineViewDiffableLoggingEnabled") as? Bool ?? false
  if !isLoggingEnabled { return }
  outlineViewDiffableLogger.error("\(message)")
}
