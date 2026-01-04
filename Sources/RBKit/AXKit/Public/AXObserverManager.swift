@preconcurrency import ApplicationServices
@preconcurrency import CoreFoundation
import Dependencies
import DependenciesMacros
import Foundation

@MainActor
public final class AXObserverManager<AX: AXClient, RunLoopClient: CFRunLoopClient>: Sendable where AX.RunLoopSource == RunLoopClient.RunLoopSource {
  
  private struct ObserverData {
    let observer: AX.Observer
    let box: Box<AX.ObserverCallback, AX.ObserverCallbackWithInfo>
  }
  
  private let client: AX
  private let runLoopClient: RunLoopClient
  private var observers: [pid_t: ObserverData] = [:]
  
  public init(client: AX, runLoopClient: RunLoopClient) {
    self.client = client
    self.runLoopClient = runLoopClient
  }
  

  public func add(notification: AXNotification, to process: pid_t, element: AX.UIElement) throws(AXClientError) {
    guard let observerData = observers[process] else {
      throw .unknown
    }
    let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(observerData.box).toOpaque())
    let result = client.observerAddNotification(observer: observerData.observer, element: element, notification: notification.rawValue as CFString, refcon: refcon)
    guard result == .success else { throw AXClientError(axError: result) }
  }

  public func notifications(for process: pid_t) -> AsyncThrowingStream<(pid_t, AX.UIElement, AXNotification), any Error> {
    let (stream, continuation) = AsyncThrowingStream.makeStream(of: (pid_t, AX.UIElement, AXNotification).self, throwing: (any Error).self)

    var outObserver: AX.Observer?
    let result = client.observerCreate(application: process, outObserver: &outObserver)
    guard result == .success else {
      continuation.finish(throwing: AXClientError(axError: result))
      return stream
    }

    guard let outObserver else {
      continuation.finish(throwing: AXClientError.unknown)
      return stream
    }
    
    // Create a box for this observer
    let box = Box<AX.ObserverCallback, AX.ObserverCallbackWithInfo>()
    observers[process] = ObserverData(observer: outObserver, box: box)
    guard let observerData = observers[process] else {
      continuation.finish(throwing: AXClientError.unknown)
      return stream
    }
    
    observerData.box.callback = { (observer: AX.Observer, uiElement: AX.UIElement, notification: CFString) in
      let notificationString = notification as String
      guard let axNotification = AXNotification(rawValue: notificationString) else { return }
      continuation.yield((process, uiElement, axNotification))
    }
    
    let runLoopSource = client.observerGetRunLoopSource(observer: observerData.observer)
    guard let currentRunLoop = runLoopClient.getCurrent() else {
      continuation.finish(throwing: AXClientError.unknown)
      return stream
    }

    continuation.onTermination = { [weak self] _ in
      Task { @MainActor in
        guard let self else { return }
        self.runLoopClient.removeSource(runLoop: currentRunLoop, source: runLoopSource, mode: .commonModes)
        self.observers.removeValue(forKey: process)
      }
    }
    
    runLoopClient.addSource(runLoop: currentRunLoop, source: runLoopSource, mode: .commonModes)

    return stream
  }
}
