import RBKit
import Dependencies
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
        for try await event in pathWatcher.events(
          paths: ["/Users/roey.biran/Desktop/test"],
          latency: 1,
          queue: nil,
          sinceWhen: nil,
          flags: .fileEvents
        ) {
          print (event)
        }
      } catch {

      }
    }
  }
}

#Preview {
  ContentView()
}
