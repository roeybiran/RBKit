import Testing
@testable import AXKit

@Suite
struct `AXClientError Tests` {

  @Test
  func `init, with .failure, should return .failure`() {
    let error = AXClientError(axError: .failure)
    #expect(error == .failure)
  }

  @Test
  func `init, with .illegalArgument, should return .illegalArgument`() {
    let error = AXClientError(axError: .illegalArgument)
    #expect(error == .illegalArgument)
  }

  @Test
  func `init, with .invalidUIElement, should return .invalidUIElement`() {
    let error = AXClientError(axError: .invalidUIElement)
    #expect(error == .invalidUIElement)
  }

  @Test
  func `init, with .invalidUIElementObserver, should return .invalidUIElementObserver`() {
    let error = AXClientError(axError: .invalidUIElementObserver)
    #expect(error == .invalidUIElementObserver)
  }

  @Test
  func `init, with .cannotComplete, should return .cannotComplete`() {
    let error = AXClientError(axError: .cannotComplete)
    #expect(error == .cannotComplete)
  }

  @Test
  func `init, with .attributeUnsupported, should return .attributeUnsupported`() {
    let error = AXClientError(axError: .attributeUnsupported)
    #expect(error == .attributeUnsupported)
  }

  @Test
  func `init, with .actionUnsupported, should return .actionUnsupported`() {
    let error = AXClientError(axError: .actionUnsupported)
    #expect(error == .actionUnsupported)
  }

  @Test
  func `init, with .notificationUnsupported, should return .notificationUnsupported`() {
    let error = AXClientError(axError: .notificationUnsupported)
    #expect(error == .notificationUnsupported)
  }

  @Test
  func `init, with .notImplemented, should return .notImplemented`() {
    let error = AXClientError(axError: .notImplemented)
    #expect(error == .notImplemented)
  }

  @Test
  func `init, with .notificationAlreadyRegistered, should return .notificationAlreadyRegistered`() {
    let error = AXClientError(axError: .notificationAlreadyRegistered)
    #expect(error == .notificationAlreadyRegistered)
  }

  @Test
  func `init, with .notificationNotRegistered, should return .notificationNotRegistered`() {
    let error = AXClientError(axError: .notificationNotRegistered)
    #expect(error == .notificationNotRegistered)
  }

  @Test
  func `init, with .apiDisabled, should return .apiDisabled`() {
    let error = AXClientError(axError: .apiDisabled)
    #expect(error == .apiDisabled)
  }

  @Test
  func `init, with .noValue, should return .noValue`() {
    let error = AXClientError(axError: .noValue)
    #expect(error == .noValue)
  }

  @Test
  func `init, with .parameterizedAttributeUnsupported, should return .parameterizedAttributeUnsupported`() {
    let error = AXClientError(axError: .parameterizedAttributeUnsupported)
    #expect(error == .parameterizedAttributeUnsupported)
  }

  @Test
  func `init, with .notEnoughPrecision, should return .notEnoughPrecision`() {
    let error = AXClientError(axError: .notEnoughPrecision)
    #expect(error == .notEnoughPrecision)
  }

  @Test
  func `init, with .success, should fallback to .unknown`() {
    let error = AXClientError(axError: .success)
    #expect(error == .unknown)
  }
}
