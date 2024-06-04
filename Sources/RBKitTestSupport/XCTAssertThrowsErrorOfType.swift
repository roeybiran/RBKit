import XCTest

/// https://www.swiftbysundell.com/articles/testing-error-code-paths-in-swift/#equatable-errors
public func XCTAssertThrowsError<T, E: Error & Equatable>(
  _ expression: @autoclosure () throws -> T,
  ofType errorType: E,
  file: StaticString = #file,
  line: UInt = #line)
{
  var thrownError: Error?

  XCTAssertThrowsError(try expression(), file: file, line: line) { thrownError = $0 }

  XCTAssertTrue(
    thrownError is E,
    "Unexpected error type: \(type(of: thrownError))",
    file: file,
    line: line)

  XCTAssertEqual(thrownError as? E, errorType, file: file, line: line)
}

/// https://www.swiftbysundell.com/articles/testing-error-code-paths-in-swift/#equatable-errors
public func XCTAssertThrowsError<T, E: Error & Equatable>(
  _ expression: @autoclosure () async throws -> T,
  ofType errorType: E,
  file: StaticString = #file,
  line: UInt = #line)
  async
{
  var thrownError: Error?

  do {
    _ = try await expression()
  } catch {
    thrownError = error
  }

  XCTAssertEqual(thrownError as? E, errorType, file: file, line: line)
}
