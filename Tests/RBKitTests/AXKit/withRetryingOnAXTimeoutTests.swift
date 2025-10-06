import Testing
import Foundation
@testable import AXKit

@Suite
struct `withRetryingOnAXTimeout Tests` {

  @Test
  func `withRetryingOnAXTimeout, with success on first try, should return value`() async throws {
    let result = try await withRetryingOnAXTimeout(
      scheduler: { _ in }
    ) {
      return 42
    }
    #expect(result == 42)
  }

  @Test
  func `withRetryingOnAXTimeout, with success after one retry, should return value`() async throws {
    var attemptCount = 0
    let result = try await withRetryingOnAXTimeout(
      scheduler: { _ in }
    ) {
      attemptCount += 1
      if attemptCount == 1 {
        throw AXClientError.cannotComplete
      }
      return "success"
    }
    #expect(result == "success")
    #expect(attemptCount == 2)
  }

  @Test
  func `withRetryingOnAXTimeout, with success after multiple retries, should return value`() async throws {
    var attemptCount = 0
    let result = try await withRetryingOnAXTimeout(
      scheduler: { _ in }
    ) {
      attemptCount += 1
      if attemptCount < 5 {
        throw AXClientError.cannotComplete
      }
      return true
    }
    #expect(result == true)
    #expect(attemptCount == 5)
  }

  @Test
  func `withRetryingOnAXTimeout, when timeout is exceeded, should throw .cannotComplete`() async throws {
    var attemptCount = 0
    await #expect(throws: AXClientError.cannotComplete) {
      try await withRetryingOnAXTimeout(
        retryingEvery: .milliseconds(10),
        until: .milliseconds(5),
        scheduler: { _ in }
      ) {
        attemptCount += 1
        throw AXClientError.cannotComplete
      }
    }
    #expect(attemptCount == 1)
  }

  @Test
  func `withRetryingOnAXTimeout, with non-.cannotComplete error, should throw immediately`() async throws {
    var attemptCount = 0
    await #expect(throws: AXClientError.failure) {
      try await withRetryingOnAXTimeout(
        scheduler: { _ in }
      ) {
        attemptCount += 1
        throw AXClientError.failure
      }
    }
    #expect(attemptCount == 1)
  }

  @Test
  func `withRetryingOnAXTimeout, with .cannotComplete then other error, should throw other error`() async throws {
    var attemptCount = 0
    await #expect(throws: AXClientError.illegalArgument) {
      try await withRetryingOnAXTimeout(
        scheduler: { _ in }
      ) {
        attemptCount += 1
        if attemptCount == 1 {
          throw AXClientError.cannotComplete
        }
        throw AXClientError.illegalArgument
      }
    }
    #expect(attemptCount == 2)
  }

  @Test
  func `withRetryingOnAXTimeout, with custom retry interval, should use interval`() async throws {
    var attemptCount = 0
    var receivedInterval: Duration?
    let result = try await withRetryingOnAXTimeout(
      retryingEvery: .milliseconds(100),
      scheduler: { duration in
        receivedInterval = duration
      }
    ) {
      attemptCount += 1
      if attemptCount == 1 {
        throw AXClientError.cannotComplete
      }
      return "done"
    }
    #expect(result == "done")
    #expect(attemptCount == 2)
    #expect(receivedInterval == .milliseconds(100))
  }

  @Test
  func `withRetryingOnAXTimeout, with non-throwing closure, should return value`() async throws {
    let result = try await withRetryingOnAXTimeout(
      scheduler: { _ in }
    ) {
      return [1, 2, 3]
    }
    #expect(result == [1, 2, 3])
  }

  @Test
  func `withRetryingOnAXTimeout, with custom timeout, should respect timeout`() async throws {
    var attemptCount = 0
    await #expect(throws: AXClientError.cannotComplete) {
      try await withRetryingOnAXTimeout(
        retryingEvery: .milliseconds(10),
        until: .milliseconds(25),
        scheduler: { _ in }
      ) {
        attemptCount += 1
        throw AXClientError.cannotComplete
      }
    }
    #expect(attemptCount == 3) // at 0ms, 10ms, 20ms (30ms would exceed timeout)
  }
}
