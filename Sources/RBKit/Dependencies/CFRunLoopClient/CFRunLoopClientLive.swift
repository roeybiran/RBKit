@preconcurrency import CoreFoundation
@preconcurrency import Foundation

// MARK: - CFRunLoopClientLive

public enum CFRunLoopClientLive {

  public struct Current: CFRunLoopClientProtocol {
    public init() { }

    public typealias RunLoop = CFRunLoop
    public typealias RunLoopSource = CFRunLoopSource

    public func getCurrent() -> RunLoop? {
      CFRunLoopGetCurrent()
    }

    public func addSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
      CFRunLoopAddSource(runLoop, source, mode)
    }

    public func removeSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
      CFRunLoopRemoveSource(runLoop, source, mode)
    }
  }

  public struct Main: CFRunLoopClientProtocol {
    public init() { }

    public typealias RunLoop = CFRunLoop
    public typealias RunLoopSource = CFRunLoopSource

    public func getCurrent() -> RunLoop? {
      CFRunLoopGetMain()
    }

    public func addSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
      CFRunLoopAddSource(runLoop, source, mode)
    }

    public func removeSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
      CFRunLoopRemoveSource(runLoop, source, mode)
    }
  }

  /// https://github.com/lwouis/alt-tab-macos/blob/master/src/util/BackgroundWork.swift
  public final class Background: Thread {

    // MARK: Lifecycle

    public init(name: String, qualityOfService: QualityOfService = .userInitiated) {
      super.init()
      self.name = name
      self.qualityOfService = qualityOfService
      start()
      ready.wait()
    }

    // MARK: Public

    public override func main() {
      runLoop = CFRunLoopGetCurrent()
      addDummySourceToPreventRunLoopTermination()
      ready.signal()
      CFRunLoopRun()
    }

    // MARK: Private

    private let ready = DispatchSemaphore(value: 0)
    private nonisolated(unsafe) var runLoop: CFRunLoop?

    private func addDummySourceToPreventRunLoopTermination() {
      var context = CFRunLoopSourceContext()
      context.perform = { _ in }

      guard let source = CFRunLoopSourceCreate(nil, 0, &context) else { return }
      CFRunLoopAddSource(runLoop, source, .commonModes)
    }

  }

}

// MARK: - CFRunLoopClientLive.Background + CFRunLoopClientProtocol

extension CFRunLoopClientLive.Background: CFRunLoopClientProtocol {

  public typealias RunLoop = CFRunLoop
  public typealias RunLoopSource = CFRunLoopSource

  public func getCurrent() -> RunLoop? {
    runLoop
  }

  public func addSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
    CFRunLoopAddSource(runLoop, source, mode)
  }

  public func removeSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
    CFRunLoopRemoveSource(runLoop, source, mode)
  }

}
