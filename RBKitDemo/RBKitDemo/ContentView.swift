import Dependencies
import Foundation
import RBKit
import SwiftUI

struct ContentView: View {
  struct Match: Identifiable {
    let candidate: String
    let score: FzyJS.Rank

    var id: String { candidate }
  }

  @Dependency(\.appWatcherClient) private var appWatcherClient
  @Dependency(\.fuzzyMatcher) private var fuzzyMatcher

  @State private var query = ""
  @State private var lines = [String]()
  @State private var matches = [Match]()
  @State private var appWatcherLogs = [String]()
  @State private var appWatcherTask: Task<Void, Never>?

  var body: some View {
    VStack {
      Section {
        List(Array(appWatcherLogs.enumerated()), id: \.offset) { _, log in
          Text(log)
            .font(.system(.body, design: .monospaced))
            .textSelection(.enabled)
        }
        .frame(minHeight: 220)
      } header: {
        HStack {
          Text("AppWatcher")
          Spacer()
          Button("Cancel Stream") {
            appWatcherTask?.cancel()
            appWatcherLogs.append("cancelled")
          }.disabled(appWatcherTask == nil)
        }
      }
      Section("Fuzzy Matcher") {
        TextField("Query", text: $query)
        List(matches) { match in
          LazyVStack(alignment: .leading) {
            Text(highlightedText(match.candidate, positions: match.score.positions)).lineLimit(1)
          }
        }
      }
    }
    .padding()
    .onAppear {
      lines = Self.loadLines()
    }
    .task {
      startAppWatcherTask()
    }
    .task(id: query) {
      matches = await updateMatches(query: query, lines: lines)
    }
    .onDisappear {
      appWatcherTask?.cancel()
    }
  }

  @concurrent
  private func updateMatches(query: String, lines: [String]) async -> [Match] {
    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    var matches = [Match]()
    matches.reserveCapacity(lines.count)

    if trimmedQuery.isEmpty {
      matches = Array(lines).map {
        Match(candidate: $0, score: .init())
      }
    } else {
      for candidate in lines {
        let score = await fuzzyMatcher.score(trimmedQuery.normalized(), candidate)

        if score.rank <= 0 {
          continue
        }

        matches.append(Match(candidate: candidate, score: score))
      }
      matches.sort { lhs, rhs in
        lhs.score.rank > rhs.score.rank
      }
    }
    return matches
  }

  private func highlightedText(_ string: String, positions: [String.Index]) -> AttributedString {
    var attributed = AttributedString(string)
    attributed.font = .system(.body, design: .monospaced)

    for position in positions {
      let upperBound = string.index(after: position)
      guard
        let attributedLowerBound = AttributedString.Index(position, within: attributed),
        let attributedUpperBound = AttributedString.Index(upperBound, within: attributed)
      else {
        continue
      }

      attributed[attributedLowerBound ..< attributedUpperBound].font = .system(.body, design: .monospaced).bold()
      attributed[attributedLowerBound ..< attributedUpperBound].foregroundColor = .blue
    }

    return attributed
  }

  private func startAppWatcherTask() {
    appWatcherTask = Task {
      for await event in appWatcherClient.events() {
        switch event {
        case .launched(let apps):
          let names = apps.map { $0.localizedName ?? "UNKNOWN" }.joined(separator: ", ")
          appWatcherLogs.append("launched: \(names)")

        case .didFinishedLaunching(let app):
          handleRunningAppEvent("didFinishedLaunching", app: app)

        case .activated(let app):
          handleRunningAppEvent("activated", app: app)

        case .deactivated(let app):
          handleRunningAppEvent("deactivated", app: app)

        case .ownedMenuBar(let app):
          handleRunningAppEvent("ownedMenuBar", app: app)

        case .disownedMenuBar(let app):
          handleRunningAppEvent("disownedMenuBar", app: app)

        case .terminated(let app):
          handleRunningAppEvent("terminated", app: app)

        case .hidden(let app):
          handleRunningAppEvent("hidden", app: app)

        case .unhidden(let app):
          handleRunningAppEvent("unhidden", app: app)

        case .activationPolicyChanged(let app):
          handleRunningAppEvent("activationPolicyChanged", app: app)
        }

        if appWatcherLogs.count > 200 {
          appWatcherLogs.removeFirst(appWatcherLogs.count - 200)
        }
      }
    }
  }

  private func handleRunningAppEvent(_ event: String, app: NSRunningApplication) {
    appWatcherLogs.append("\(event): \(app.localizedName ?? "UNKNOWN")")
  }

  private static func loadLines() -> [String] {
    guard
      let url = Bundle.main.url(forResource: "rails_files", withExtension: "txt"),
      let contents = try? String(contentsOf: url, encoding: .utf8)
    else {
      return []
    }

    return contents
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map(String.init)
  }

  private static let resultLimit = 300
}

#Preview {
  ContentView()
}
