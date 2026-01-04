import Foundation
import ApplicationServices
import Testing
@testable import AXKit
import AXKitTestSupport

@Suite
@MainActor
struct `AXObserverManager Tests` {

  @Test
  func `notifications, with valid pid, should create observer and return stream`() async throws {
    nonisolated(unsafe) var didCreateObserver = false
    let mockClient = AXClientMock()
    var mockRunLoopClient = CFRunLoopClientMock()
    let pid: pid_t = 12345
    let expectedObserver = ObserverMock(id: "test-observer-123")
    
    mockClient._observerCreate = { receivedPid, _, outObserver in
      #expect(receivedPid == pid)
      outObserver.pointee = expectedObserver
      didCreateObserver = true
      return .success
    }
    mockClient._observerGetRunLoopSource = { _ in RunLoopSourceMock() }
    mockRunLoopClient._getCurrent = { RunLoopSourceMock() }
    
    let manager = AXObserverManager(client: mockClient, runLoopClient: mockRunLoopClient)
    let stream = manager.notifications(for: pid)
    
    #expect(didCreateObserver == true)
    
    // Cancel the stream to clean up
    let task = Task {
      for try await _ in stream {
        break
      }
    }
    task.cancel()
    try? await task.value
  }

  @Test
  func `notifications, with AXError, should finish stream with error`() async throws {
    let mockClient = AXClientMock()
    var mockRunLoopClient = CFRunLoopClientMock()
    
    mockClient._observerCreate = { _, _, _ in .failure }
    mockRunLoopClient._getCurrent = { RunLoopSourceMock() }
    
    let manager = AXObserverManager(client: mockClient, runLoopClient: mockRunLoopClient)
    let stream = manager.notifications(for: 12345)
    
    var didThrow = false
    do {
      for try await _ in stream {
        break
      }
    } catch {
      didThrow = true
      #expect(error is AXClientError)
    }
    #expect(didThrow == true)
  }

  @Test
  func `notifications, with success but nil observer, should finish stream with error`() async throws {
    let mockClient = AXClientMock()
    var mockRunLoopClient = CFRunLoopClientMock()
    
    mockClient._observerCreate = { _, _, outObserver in
      outObserver.pointee = nil  // Success but nil observer
      return .success
    }
    mockRunLoopClient._getCurrent = { RunLoopSourceMock() }
    
    let manager = AXObserverManager(client: mockClient, runLoopClient: mockRunLoopClient)
    let stream = manager.notifications(for: 12345)
    
    var didThrow = false
    do {
      for try await _ in stream {
        break
      }
    } catch {
      didThrow = true
      #expect(error is AXClientError)
    }
    #expect(didThrow == true)
  }

  @Test
  func `add, with valid notification, should add notification to observer`() async throws {
    nonisolated(unsafe) var didAddNotification = false
    let mockClient = AXClientMock()
    var mockRunLoopClient = CFRunLoopClientMock()
    let pid: pid_t = 12345
    let expectedObserver = ObserverMock(id: "test-observer-123")
    let element = UIElementMock()
    let notification = AXNotification.titleChanged
    
    mockClient._observerCreate = { _, _, outObserver in
      outObserver.pointee = expectedObserver
      return .success
    }
    mockClient._observerGetRunLoopSource = { _ in RunLoopSourceMock() }
    mockClient._observerAddNotification = { observer, receivedElement, receivedNotification in
      #expect(observer == expectedObserver)
      #expect(receivedElement === element)
      #expect(receivedNotification == notification.rawValue as CFString)
      didAddNotification = true
      return .success
    }
    mockRunLoopClient._getCurrent = { RunLoopSourceMock() }
    
    let manager = AXObserverManager(client: mockClient, runLoopClient: mockRunLoopClient)
    _ = manager.notifications(for: pid)  // Create observer first
    
    try manager.add(notification: notification, to: pid, element: element)
    #expect(didAddNotification == true)
  }

  @Test
  func `add, with unknown process, should throw`() async {
    let mockClient = AXClientMock()
    let mockRunLoopClient = CFRunLoopClientMock()
    let element = UIElementMock()
    let notification = AXNotification.titleChanged
    
    let manager = AXObserverManager(client: mockClient, runLoopClient: mockRunLoopClient)
    
    #expect(throws: AXClientError.unknown) {
      try manager.add(notification: notification, to: 12345, element: element)
    }
  }
}

