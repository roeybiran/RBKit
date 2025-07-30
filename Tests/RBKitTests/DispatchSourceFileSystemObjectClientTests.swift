import Testing
import Dependencies
import Foundation
@testable import RBKit

@Suite
struct DispatchSourceFileSystemObjectClientTests {
  @Test
  func pathMonitor_withMockSource_shouldCallAllRequiredMethods() async throws {
    withDependencies {
      $0.dispatchSourceFileSystemObjectClient.make = { fd, mask, queue in
        DispatchSourceFileSystemObjectMock()
      }
      $0.dispatchSourceFileSystemObjectClient.cancel = { _ in }
      $0.dispatchSourceFileSystemObjectClient.resume = { _ in }
      $0.dispatchSourceFileSystemObjectClient.setEventHandler = { _, _, _, _ in }
      $0.dispatchSourceFileSystemObjectClient.data = { _ in .write }
      $0.dispatchSourceFileSystemObjectClient.handle = { _ in
        open(NSTemporaryDirectory(), O_EVTONLY)
      }
    } operation: {
      @Dependency(\.dispatchSourceFileSystemObjectClient) var client
      
      let task = Task {
        for await event in client.pathMonitor(path: NSTemporaryDirectory(), mask: .write, queue: nil) {
          #expect(event == .write)
          break
        }
      }
      task.cancel()
      
    }
  }
}
