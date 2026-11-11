import Dependencies
import HotKeyRecorder
import RBKit
import SwiftUI

// MARK: - DemoHotKeyID

enum DemoHotKeyID {
  static let toggleApp: HotKey.ID = 1
  static let toggleSearch: HotKey.ID = 2
}

// MARK: - HotKeyRecorderDemo

struct HotKeyRecorderDemo: View {

  // MARK: Internal

  var body: some View {
    VStack {
      List(
        [
          HotKeyConfiguration(id: DemoHotKeyID.toggleApp, title: "Toggle Finbar"),
          HotKeyConfiguration(id: DemoHotKeyID.toggleSearch, title: "Show Debug Menu"),
        ],
        id: \.id,
      ) { configuration in
        HotKeyRecorderView(configuration: configuration)
      }
      .frame(minHeight: 100)
      ScrollViewReader { scrollView in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(Array(eventLogLines.enumerated()), id: \.offset) { index, line in
              Text(line)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(index)
            }
          }
          .padding(8)
        }
        .font(.system(.body, design: .monospaced))
        .frame(height: 140)
        .border(Color.gray.opacity(0.3), width: 1)
        .onChange(of: eventLogLines.count) {
          guard let lastIndex = eventLogLines.indices.last else { return }
          scrollView.scrollTo(lastIndex, anchor: .bottom)
        }
      }
    }
    .padding()
    .onAppear {
      HotKeyManagerClient.migrateLegacyDefaults([
        "toggleApp": DemoHotKeyID.toggleApp,
        "toggleSearch": DemoHotKeyID.toggleSearch,
      ])
      hotKeyManagerClient.registerDefaults([
        DemoHotKeyID.toggleApp: .init(key: .f2, modifiers: []),
        DemoHotKeyID.toggleSearch: .init(key: .v, modifiers: [.command, .control, .option, .shift]),
      ])
    }
    .task {
      hotKeyManagerClient.start()
      let hotKeyPresses = hotKeyManagerClient.presses(DemoHotKeyID.toggleApp)

      for await event in hotKeyPresses {
        let line = "\(Date.now) - toggle app - \(event)"
        eventLogLines.append(line)
      }
    }
    .task {
      hotKeyManagerClient.start()
      let hotKeyPresses = hotKeyManagerClient.presses(DemoHotKeyID.toggleSearch)

      for await event in hotKeyPresses {
        let line = "\(Date.now) - toggle search - \(event)"
        eventLogLines.append(line)
      }
    }
  }

  // MARK: Private

  @Dependency(\.hotKeyManagerClient) private var hotKeyManagerClient
  @State private var eventLogLines = [String]()

}
