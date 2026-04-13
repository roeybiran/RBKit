import Carbon

public final class BoxedHotKeyHandler {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var callback: @MainActor @Sendable (EventRef?) -> OSStatus = { _ in
    OSStatus(eventNotHandledErr)
  }
}
