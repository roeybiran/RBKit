import Carbon

public class BoxedEventHandler {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var eventHandler: (_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent) -> Unmanaged<CGEvent>? = { _, _, _ in
    nil
  }
}
