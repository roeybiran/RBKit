import Dependencies

// https://github.com/lwouis/alt-tab-macos/blob/master/src/api-wrappers/AXUIElement.swift
nonisolated public func withRetryingOnAXTimeout<T>(
  retryingEvery interval: Duration = .seconds(0.25),
  until timeout: Duration = .seconds(120),
  execute closure: @Sendable () throws -> T,
) async throws -> T {
  @Dependency(\.continuousClock) var clock

  var elapsed = Duration.seconds(0)

  while elapsed < timeout {
    do {
      return try closure()
    } catch AXClientError.cannotComplete {
      try? await clock.sleep(for: interval)
      elapsed += interval
    } catch {
      throw error
    }
  }

  throw AXClientError.cannotComplete
}
