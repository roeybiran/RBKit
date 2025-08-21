@preconcurrency import ApplicationServices
import Dependencies
import DependenciesMacros
import Foundation
import CoreFoundation

extension AXClient {
  public func createObserver(application: pid_t) throws(AXClientError) -> Observer {
    var outObserver: Observer?
    let result = observerCreate(application: application, outObserver: &outObserver)
    guard result == .success else { throw AXClientError(axError: result) }
    guard let outObserver else { throw .unknown }
    return outObserver
  }

  public func addNotification(observer: Observer, element: UIElement, notification: AXNotification) throws(AXClientError) {
    let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(box).toOpaque())
    let result = observerAddNotification(observer: observer, element: element, notification: notification.rawValue as CFString, refcon: refcon)
    guard result == .success else { throw AXClientError(axError: result) }
  }

  @MainActor
  public func start(observer: Observer) -> AsyncStream<(Observer, UIElement, AXNotification)> {
    MainActor.preconditionIsolated()
    let (stream, continuation) = AsyncStream.makeStream(of: (Observer, UIElement, AXNotification).self)
    box.callback = { observer, uiElement, notification in
      guard let notification = AXNotification(rawValue: notification as String) else { return }
      continuation.yield((observer, uiElement, notification))
    }
    continuation.onTermination = { _ in
      removeRunLoopSource(runLoop: CFRunLoopGetCurrent(), source: observerGetRunLoopSource(observer: observer), mode: .commonModes)
    }
    addRunLoopSource(runLoop: CFRunLoopGetCurrent(), source: observerGetRunLoopSource(observer: observer), mode: .commonModes)
    let src = observerGetRunLoopSource(observer: observer)

    return stream
  }
}
