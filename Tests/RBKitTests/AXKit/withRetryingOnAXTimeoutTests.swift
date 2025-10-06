import Testing
import Foundation
import Dependencies
@testable import AXKit

struct withRetryingOnAXTimeoutTests {

  @Test
  func withRetryingOnAXTimeout_withSuccessOnFirstTry_shouldReturnValue() async throws {
    try await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      let result = try await withRetryingOnAXTimeout {
        return 42
      }
      #expect(result == 42)
    }
  }

  @Test
  func withRetryingOnAXTimeout_withSuccessAfterOneRetry_shouldReturnValue() async throws {
    try await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      var attemptCount = 0
      let result = try await withRetryingOnAXTimeout {
        attemptCount += 1
        if attemptCount == 1 {
          throw AXClientError.cannotComplete
        }
        return "success"
      }
      #expect(result == "success")
      #expect(attemptCount == 2)
    }
  }

  @Test
  func withRetryingOnAXTimeout_withSuccessAfterMultipleRetries_shouldReturnValue() async throws {
    try await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      var attemptCount = 0
      let result = try await withRetryingOnAXTimeout {
        attemptCount += 1
        if attemptCount < 5 {
          throw AXClientError.cannotComplete
        }
        return true
      }
      #expect(result == true)
      #expect(attemptCount == 5)
    }
  }

  @Test
  func withRetryingOnAXTimeout_withTimeout_shouldThrowCannotComplete() async throws {
    await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      var attemptCount = 0
      await #expect(throws: AXClientError.cannotComplete) {
        try await withRetryingOnAXTimeout(retryingEvery: .seconds(1)) {
          attemptCount += 1
          throw AXClientError.cannotComplete
        }
      }
      #expect(attemptCount > 0)
    }
  }

  @Test
  func withRetryingOnAXTimeout_withOtherError_shouldThrowImmediately() async throws {
    await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      var attemptCount = 0
      await #expect(throws: AXClientError.failure) {
        try await withRetryingOnAXTimeout {
          attemptCount += 1
          throw AXClientError.failure
        }
      }
      #expect(attemptCount == 1)
    }
  }

  @Test
  func withRetryingOnAXTimeout_withCannotCompleteThenOtherError_shouldThrowOtherError() async throws {
    await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      var attemptCount = 0
      await #expect(throws: AXClientError.illegalArgument) {
        try await withRetryingOnAXTimeout {
          attemptCount += 1
          if attemptCount == 1 {
            throw AXClientError.cannotComplete
          }
          throw AXClientError.illegalArgument
        }
      }
      #expect(attemptCount == 2)
    }
  }

  @Test
  func withRetryingOnAXTimeout_withCustomRetryInterval_shouldUseInterval() async throws {
    try await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      var attemptCount = 0
      let result = try await withRetryingOnAXTimeout(retryingEvery: .milliseconds(100)) {
        attemptCount += 1
        if attemptCount == 1 {
          throw AXClientError.cannotComplete
        }
        return "done"
      }
      #expect(result == "done")
      #expect(attemptCount == 2)
    }
  }

  @Test
  func withRetryingOnAXTimeout_withNonThrowingClosure_shouldReturnValue() async throws {
    try await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      let result = try await withRetryingOnAXTimeout {
        return [1, 2, 3]
      }
      #expect(result == [1, 2, 3])
    }
  }
}
