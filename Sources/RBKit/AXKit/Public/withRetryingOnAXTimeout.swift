import Foundation
import AXKit

// https://github.com/lwouis/alt-tab-macos/blob/master/src/api-wrappers/AXUIElement.swift
nonisolated public func withRetryingOnAXTimeout<T>(
  timeout: TimeInterval = 120,
  retryEvery interval: Duration = .seconds(0.25),
  execute closure: () throws -> T,
) async throws -> T {
  let startTime = Date()
  while Date().timeIntervalSince(startTime) < timeout {
    do {
      return try closure()
    } catch AXClientError.cannotComplete {
      try? await Task.sleep(for: interval)
    } catch {
      throw error
    }
  }
  throw AXClientError.cannotComplete
}
