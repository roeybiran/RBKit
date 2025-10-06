import Foundation
import Dependencies

// https://github.com/lwouis/alt-tab-macos/blob/master/src/api-wrappers/AXUIElement.swift
nonisolated public func withRetryingOnAXTimeout<T>(
  retryingEvery interval: Duration = .seconds(0.25),
  until timeout: Duration = .seconds(120),
  execute closure: () throws -> T,
) async throws -> T {
  @Dependency(\.continuousClock) var clock

  var elapsed = Duration.seconds(0)

  for await _ in clock.timer(interval: interval) {
    if elapsed > timeout { break }

    do {
      return try closure()
    } catch AXClientError.cannotComplete {
      elapsed += interval
      continue
    } catch {
      throw error
    }
  }
  throw AXClientError.cannotComplete
}
