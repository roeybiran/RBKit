import Foundation
import Dependencies

// https://github.com/lwouis/alt-tab-macos/blob/master/src/api-wrappers/AXUIElement.swift
nonisolated public func withRetryingOnAXTimeout<T>(
  retryingEvery interval: Duration = .seconds(0.25),
  until timeout: Duration = .seconds(120),
  scheduler: (_ duration: Duration) async throws -> Void,
  execute closure: () throws -> T,
) async throws -> T {

  var elapsed = Duration.seconds(0)

  while elapsed < timeout {
    do {
      return try closure()
    } catch AXClientError.cannotComplete {
      try? await scheduler(interval)
      elapsed += interval
    } catch {
      throw error
    }
  }

  throw AXClientError.cannotComplete
}
