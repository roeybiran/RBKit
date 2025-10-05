import Foundation
import AXKit
import Dependencies

// https://github.com/lwouis/alt-tab-macos/blob/master/src/api-wrappers/AXUIElement.swift
nonisolated public func withRetryingOnAXTimeout<T>(
  timeout: TimeInterval = 120,
  retryEvery interval: Duration = .seconds(0.25),
  execute closure: () throws -> T,
) async throws -> T {
  @Dependency(\.date) var dateClient
  @Dependency(\.continuousClock) var clock
  let startTime = dateClient.now
  while dateClient.now.timeIntervalSince(startTime) < timeout {
    do {
      return try closure()
    } catch AXClientError.cannotComplete {
      try? await clock.sleep(for: interval)
    } catch {
      throw error
    }
  }
  throw AXClientError.cannotComplete
}
