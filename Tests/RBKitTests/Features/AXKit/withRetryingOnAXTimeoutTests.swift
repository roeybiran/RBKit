import Dependencies
import Foundation
import Testing
@testable import RBKit

@Suite
struct `withRetryingOnAXTimeout Tests` {

  @Test
  func `withRetryingOnAXTimeout, with success on first try, should return value`() async throws {
    let clock = TestClock()
    let result = try await withDependencies {
      $0.continuousClock = clock
    } operation: {
      try await withRetryingOnAXTimeout {
        42
      }
    }
    #expect(result == 42)
  }

  @Test
  func `withRetryingOnAXTimeout, with success after one retry, should return value`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    let task = Task {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout {
          attemptCount += 1
          if attemptCount == 1 {
            throw AXClientError.cannotComplete
          }
          return "success"
        }
      }
    }
    await clock.advance(by: .seconds(0.25))
    let result = try await task.value
    #expect(result == "success")
    #expect(attemptCount == 2)
  }

  @Test
  func `withRetryingOnAXTimeout, with success after multiple retries, should return value`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    let task = Task {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout {
          attemptCount += 1
          if attemptCount < 5 {
            throw AXClientError.cannotComplete
          }
          return true
        }
      }
    }
    await clock.advance(by: .seconds(1.0)) // Advance past all retries
    let result = try await task.value
    #expect(result == true)
    #expect(attemptCount == 5)
  }

  @Test
  func `withRetryingOnAXTimeout, when timeout is exceeded, should throw .cannotComplete`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    let task = Task {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout(
          retryingEvery: .milliseconds(10),
          until: .milliseconds(5),
        ) {
          attemptCount += 1
          throw AXClientError.cannotComplete
        }
      }
    }
    await clock.advance(by: .milliseconds(10))
    await #expect(throws: AXClientError.cannotComplete) {
      try await task.value
    }
    #expect(attemptCount == 1)
  }

  @Test
  func `withRetryingOnAXTimeout, with non-.cannotComplete error, should throw immediately`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    await #expect(throws: AXClientError.failure) {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout {
          attemptCount += 1
          throw AXClientError.failure
        }
      }
    }
    #expect(attemptCount == 1)
  }

  @Test
  func `withRetryingOnAXTimeout, with .cannotComplete then other error, should throw other error`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    let task = Task {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout {
          attemptCount += 1
          if attemptCount == 1 {
            throw AXClientError.cannotComplete
          }
          throw AXClientError.illegalArgument
        }
      }
    }
    await clock.advance(by: .seconds(0.25))
    await #expect(throws: AXClientError.illegalArgument) {
      try await task.value
    }
    #expect(attemptCount == 2)
  }

  @Test
  func `withRetryingOnAXTimeout, with custom retry interval, should use interval`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    let task = Task {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout(
          retryingEvery: .milliseconds(100)
        ) {
          attemptCount += 1
          if attemptCount == 1 {
            throw AXClientError.cannotComplete
          }
          return "done"
        }
      }
    }
    await clock.advance(by: .milliseconds(100))
    let result = try await task.value
    #expect(result == "done")
    #expect(attemptCount == 2)
  }

  @Test
  func `withRetryingOnAXTimeout, with non-throwing closure, should return value`() async throws {
    let clock = TestClock()
    let result = try await withDependencies {
      $0.continuousClock = clock
    } operation: {
      try await withRetryingOnAXTimeout {
        [1, 2, 3]
      }
    }
    #expect(result == [1, 2, 3])
  }

  @Test
  func `withRetryingOnAXTimeout, with custom timeout, should respect timeout`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    let task = Task {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout(
          retryingEvery: .milliseconds(10),
          until: .milliseconds(25),
        ) {
          attemptCount += 1
          throw AXClientError.cannotComplete
        }
      }
    }
    await clock.advance(by: .milliseconds(30))
    await #expect(throws: AXClientError.cannotComplete) {
      try await task.value
    }
    #expect(attemptCount == 3) // at 0ms, 10ms, 20ms (30ms would exceed timeout)
  }

  @Test
  func `withRetryingOnAXTimeout, with slow attempts, should count attempt time toward timeout`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    let task = Task {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout(
          retryingEvery: .seconds(1),
          until: .seconds(10),
        ) {
          attemptCount += 1
          try await clock.sleep(for: .seconds(6)) // e.g. the AX messaging timeout of a hung app
          throw AXClientError.cannotComplete
        }
      }
    }
    await clock.advance(by: .seconds(14))
    await #expect(throws: AXClientError.cannotComplete) {
      try await task.value
    }
    #expect(attemptCount == 2) // at 0s–6s and 7s–13s; 14s is past the timeout
  }

  @Test
  func `withRetryingOnAXTimeout, when cancelled between attempts, should throw CancellationError without retrying`() async throws {
    let clock = TestClock()
    nonisolated(unsafe) var attemptCount = 0
    let (attempts, continuation) = AsyncStream.makeStream(of: Void.self)
    let task = Task {
      try await withDependencies {
        $0.continuousClock = clock
      } operation: {
        try await withRetryingOnAXTimeout {
          attemptCount += 1
          continuation.yield()
          throw AXClientError.cannotComplete
        }
      }
    }
    for await _ in attempts { break }
    task.cancel()
    await #expect(throws: CancellationError.self) {
      try await task.value
    }
    #expect(attemptCount == 1)
  }
}
