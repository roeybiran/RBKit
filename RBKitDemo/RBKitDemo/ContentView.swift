import Dependencies
import RBKit
import SwiftUI

struct ContentView: View {
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
            print(e.path, e.flag)
          }
        }
      } catch { }
    }
  }
}

#Preview {
  ContentView()
}
