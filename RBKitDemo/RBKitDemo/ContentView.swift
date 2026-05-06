import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      AppWatcherDemo()
      Divider()
      FuzzyMatcherDemo()
      Divider()
      AppPickerDemo()
      Divider()
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
