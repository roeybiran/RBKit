import Dependencies
import OSLog
import RBKit
import SwiftUI

struct ContentView: View {

  // MARK: Internal

  @Dependency(\.pathWatcherClient) var pathWatcher

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
    }
    .padding()
    .task {
      do {
        for try await event in pathWatcher.watchPathsRecursively(
          ["/Users/roey.biran/Library/Application Support/com.apple.sharedfilelist/"],
          1,
          nil,
          nil,
          .fileEvents,
        ) {
          for e in event {
            logger.debug("Path watcher event: \(e.path, privacy: .public) \(String(describing: e.flag), privacy: .public)")
          }
        }
      } catch { }
    }
  }

  // MARK: Private

  private let logger = Logger(subsystem: "RBKitDemo", category: "ContentView")

}

#Preview {
  ContentView()
}
