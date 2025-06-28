import Foundation

@available(swift, deprecated: 6.2, message: "use expect(processExitsWith:)")
public func runtimeAssert(
  _ condition: @autoclosure () -> Bool,
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file,
  line: UInt = #line)
{
  #if DEBUG
  if NSClassFromString("XCTestCase") == nil {
    assert(condition(), message(), file: file, line: line)
  }
  #endif
}

@available(swift, deprecated: 6.2, message: "use expect(processExitsWith:)")
public func runtimeAssertionFailure(
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file,
  line: UInt = #line)
{
  #if DEBUG
  if NSClassFromString("XCTestCase") == nil {
    assertionFailure(message(), file: file, line: line)
  }
  #endif
}
