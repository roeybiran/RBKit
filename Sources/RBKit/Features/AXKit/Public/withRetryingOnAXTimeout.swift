import Dependencies

/// https://github.com/lwouis/alt-tab-macos/blob/master/src/api-wrappers/AXUIElement.swift
nonisolated public func withRetryingOnAXTimeout<T>(
  retryingEvery interval: Duration = .seconds(0.25),
  until timeout: Duration = .seconds(120),
  execute closure: @Sendable () async throws -> T,
) async throws -> T {
  @Dependency(\.continuousClock) var clock

  func retry(on clock: some Clock<Duration>) async throws -> T {
    let deadline = clock.now.advanced(by: timeout)

    while clock.now < deadline {
      try Task.checkCancellation()
      do {
        return try await closure()
      } catch AXClientError.cannotComplete {
        try await clock.sleep(for: interval)
      }
    }

    throw AXClientError.cannotComplete
  }

  return try await retry(on: clock)
}
