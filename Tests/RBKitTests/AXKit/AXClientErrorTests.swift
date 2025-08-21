import Testing
@testable import AXKit

struct AXClientErrorTests {

  @Test
  func init_withFailureAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .failure)
    #expect(error == .failure)
  }

  @Test
  func init_withIllegalArgumentAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .illegalArgument)
    #expect(error == .illegalArgument)
  }

  @Test
  func init_withInvalidUIElementAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .invalidUIElement)
    #expect(error == .invalidUIElement)
  }

  @Test
  func init_withInvalidUIElementObserverAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .invalidUIElementObserver)
    #expect(error == .invalidUIElementObserver)
  }

  @Test
  func init_withCannotCompleteAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .cannotComplete)
    #expect(error == .cannotComplete)
  }

  @Test
  func init_withAttributeUnsupportedAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .attributeUnsupported)
    #expect(error == .attributeUnsupported)
  }

  @Test
  func init_withActionUnsupportedAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .actionUnsupported)
    #expect(error == .actionUnsupported)
  }

  @Test
  func init_withNotificationUnsupportedAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .notificationUnsupported)
    #expect(error == .notificationUnsupported)
  }

  @Test
  func init_withNotImplementedAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .notImplemented)
    #expect(error == .notImplemented)
  }

  @Test
  func init_withNotificationAlreadyRegisteredAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .notificationAlreadyRegistered)
    #expect(error == .notificationAlreadyRegistered)
  }

  @Test
  func init_withNotificationNotRegisteredAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .notificationNotRegistered)
    #expect(error == .notificationNotRegistered)
  }

  @Test
  func init_withApiDisabledAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .apiDisabled)
    #expect(error == .apiDisabled)
  }

  @Test
  func init_withNoValueAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .noValue)
    #expect(error == .noValue)
  }

  @Test
  func init_withParameterizedAttributeUnsupportedAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .parameterizedAttributeUnsupported)
    #expect(error == .parameterizedAttributeUnsupported)
  }

  @Test
  func init_withNotEnoughPrecisionAXError_shouldReturnCorrectError() {
    let error = AXClientError(axError: .notEnoughPrecision)
    #expect(error == .notEnoughPrecision)
  }

  @Test
  func init_withSuccessAXError_shouldFallBackToUnknown() {
    let error = AXClientError(axError: .success)
    #expect(error == .unknown)
  }
}
