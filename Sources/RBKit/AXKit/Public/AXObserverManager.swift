@preconcurrency import ApplicationServices
@preconcurrency import CoreFoundation
import Dependencies
import DependenciesMacros
import Foundation
import RBKit

public actor AXObserverManager<AXClient: AXClientProtocol, RunLoopClient: CFRunLoopClientProtocol>
  where AXClient.RunLoopSource == RunLoopClient.RunLoopSource
{

  // MARK: Lifecycle

  public init(client: AXClient, runLoopClient: RunLoopClient) {
    self.client = client
    self.runLoopClient = runLoopClient
  }

  // MARK: Public

  public func createObserver(process: pid_t) throws(AXClientError) {
    var outObserver: AXClient.Observer?
    let result = client.observerCreate(application: process, outObserver: &outObserver)
    guard result == .success else {
      throw AXClientError(axError: result)
    }

    guard let outObserver else {
      throw AXClientError.unknown
    }

    let box = Box<AXClient.ObserverCallback, AXClient.ObserverCallbackWithInfo>()
    observers[process] = ObserverData(observer: outObserver, box: box)
  }

  public func add(notification: AXNotification, to process: pid_t, element: AXClient.UIElement) throws(AXClientError) {
    guard let observerData = observers[process] else {
      throw .unknown
    }
    let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(observerData.box).toOpaque())
    let result = client.observerAddNotification(
      observer: observerData.observer,
      element: element,
      notification: notification.rawValue as CFString,
      refcon: refcon,
    )
    guard result == .success else {
      throw AXClientError(axError: result)
    }
  }

  public func notifications(for process: pid_t) -> AsyncThrowingStream<(pid_t, AXClient.UIElement, AXNotification), any Error> {
    let (stream, continuation) = AsyncThrowingStream.makeStream(
      of: (pid_t, AXClient.UIElement, AXNotification).self,
      throwing: (any Error).self,
    )

    guard let observerData = observers[process] else {
      assertionFailure()
      continuation.finish(throwing: AXClientError.unknown)
      return stream
    }

    observerData.box.callback = { _, uiElement, notification in
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
      Task {
        await self?.removeObserver(process: process, runLoop: currentRunLoop, source: runLoopSource)
      }
    }

    runLoopClient.addSource(runLoop: currentRunLoop, source: runLoopSource, mode: .commonModes)

    return stream
  }

  // MARK: Private

  private struct ObserverData {
    let observer: AXClient.Observer
    let box: Box<AXClient.ObserverCallback, AXClient.ObserverCallbackWithInfo>
  }

  private let client: AXClient
  private let runLoopClient: RunLoopClient
  private var observers = [pid_t: ObserverData]()

  private func removeObserver(process: pid_t, runLoop: RunLoopClient.RunLoop, source: RunLoopClient.RunLoopSource) {
    runLoopClient.removeSource(runLoop: runLoop, source: source, mode: .commonModes)
    observers.removeValue(forKey: process)
  }

}
