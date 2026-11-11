import SwiftUI

// MARK: - DemoPage

enum DemoPage: String, CaseIterable, Identifiable {
  case appWatcher = "AppWatcher"
  case fuzzyMatcher = "FuzzyMatcher"
  case appPicker = "AppPicker"
  case axKit = "AXKit"
  case outlineViewDiffable = "OutlineViewDiffable"
  case uiComponents = "UI Components"

  var id: Self {
    self
  }
}

// MARK: - ContentView

struct ContentView: View {

  // MARK: Internal

  var body: some View {
    NavigationSplitView {
      List(DemoPage.allCases, selection: $selection) { page in
        Text(page.rawValue)
      }
      .navigationSplitViewColumnWidth(min: 160, ideal: 180)
    } detail: {
      switch selection {
      case .appWatcher:
        AppWatcherDemo().padding()
      case .fuzzyMatcher:
        FuzzyMatcherDemo().padding()
      case .appPicker:
        AppPickerDemo().padding()
      case .axKit:
        AXKitDemo()
      case .outlineViewDiffable:
        OutlineViewDiffableDemo()
      case .uiComponents:
        UIComponentsDemo()
      case nil:
        Text("Select a demo")
      }
    }
    .frame(minWidth: 800, minHeight: 600)
  }

  // MARK: Private

  @State private var selection: DemoPage? = .appWatcher
}

#Preview {
  ContentView()
}
