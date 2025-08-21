import ApplicationServices

public enum AXClientError: Error {
  case failure
  case illegalArgument
  case invalidUIElement
  case invalidUIElementObserver
  case cannotComplete
  case attributeUnsupported
  case actionUnsupported
  case notificationUnsupported
  case notImplemented
  case notificationAlreadyRegistered
  case notificationNotRegistered
  case apiDisabled
  case noValue
  case parameterizedAttributeUnsupported
  case notEnoughPrecision
  case unknown

  // MARK: Lifecycle

  init(axError: AXError) {
    switch axError {
    case .failure:
      self = .failure

    case .illegalArgument:
      self = .illegalArgument

    case .invalidUIElement:
      self = .invalidUIElement

    case .invalidUIElementObserver:
      self = .invalidUIElementObserver

    case .cannotComplete:
      self = .cannotComplete

    case .attributeUnsupported:
      self = .attributeUnsupported

    case .actionUnsupported:
      self = .actionUnsupported

    case .notificationUnsupported:
      self = .notificationUnsupported

    case .notImplemented:
      self = .notImplemented

    case .notificationAlreadyRegistered:
      self = .notificationAlreadyRegistered

    case .notificationNotRegistered:
      self = .notificationNotRegistered

    case .apiDisabled:
      self = .apiDisabled

    case .noValue:
      self = .noValue

    case .parameterizedAttributeUnsupported:
      self = .parameterizedAttributeUnsupported

    case .notEnoughPrecision:
      self = .notEnoughPrecision

    case .success:
      // TODO: Swift 6.2 `processToExit`
      // assertionFailure()
      fallthrough

    @unknown default:
      self = .unknown
    }
  }
}
