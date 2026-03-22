import Dependencies
import Foundation
import RBKit
import SwiftUI

struct ContentView: View {
  struct Match: Identifiable {
    let candidate: String
    let score: ScoreV2

    var id: String { candidate }
  }

  @Dependency(\.appWatcherClient) private var appWatcherClient
  @Dependency(\.fuzzyMatcherV2) private var fuzzyMatcherV2

  @State private var query = ""
  @State private var totalMatchCount = 0
  @State private var visibleMatches = [Match]()
  @State private var allCandidates = [String]()
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
        List(visibleMatches) { match in
          highlightedText(for: match).lineLimit(1)
        }
      }
    }
    .padding()
    .task {
      appWatcherTask = Task {
        for await event in appWatcherClient.events() {
          switch event {
          case .launched(let apps):
            let names = apps.map { $0.localizedName ?? "UNKNOWN" }.joined(separator: ", ")
            appWatcherLogs.append("launched: \(names)")

          case .didFinishedLaunching(let app):
            appWatcherLogs.append("didFinishedLaunching: \(app.localizedName ?? "UNKNOWN")")

          case .activated(let app):
            appWatcherLogs.append("activated: \(app.localizedName ?? "UNKNOWN")")

          case .deactivated(let app):
            appWatcherLogs.append("deactivated: \(app.localizedName ?? "UNKNOWN")")

          case .terminated(let app):
            appWatcherLogs.append("terminated: \(app.localizedName ?? "UNKNOWN")")

          case .hidden(let app):
            appWatcherLogs.append("hidden: \(app.localizedName ?? "UNKNOWN")")

          case .unhidden(let app):
            appWatcherLogs.append("unhidden: \(app.localizedName ?? "UNKNOWN")")

          case .activationPolicyChanged(let app):
            appWatcherLogs.append("activationPolicyChanged: \(app.localizedName ?? "UNKNOWN")")
          }

          if appWatcherLogs.count > 200 {
            appWatcherLogs.removeFirst(appWatcherLogs.count - 200)
          }
        }
      }
    }
    .task(id: query) {
      if
        allCandidates.isEmpty,
        let url = Bundle.main.url(forResource: "rails_files", withExtension: "txt"),
        let contents = try? String(contentsOf: url, encoding: .utf8)
      {
        allCandidates = contents
          .split(separator: "\n", omittingEmptySubsequences: false)
          .map(String.init)
      }

      await updateMatches()
    }
    .onDisappear {
      appWatcherTask?.cancel()
      appWatcherTask = nil
    }
  }

  private func updateMatches() async {
    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmedQuery.isEmpty {
      totalMatchCount = allCandidates.count
      visibleMatches = Array(allCandidates.prefix(Self.resultLimit)).map {
        Match(candidate: $0, score: ScoreV2(rank: 1, hasMatch: true))
      }
      return
    }

    var matches = [Match]()
    matches.reserveCapacity(allCandidates.count)

    for candidate in allCandidates {
      let score = await fuzzyMatcherV2.score(trimmedQuery.normalized(), candidate)
      if !score.hasMatch {
        continue
      }

      matches.append(Match(candidate: candidate, score: score))
    }

    matches.sort { lhs, rhs in
      if lhs.score.rank != rhs.score.rank {
        return lhs.score.rank > rhs.score.rank
      }
      if lhs.candidate.count != rhs.candidate.count {
        return lhs.candidate.count < rhs.candidate.count
      }
      return lhs.candidate < rhs.candidate
    }

    totalMatchCount = matches.count
    visibleMatches = Array(matches.prefix(Self.resultLimit))
  }

  private func highlightedText(for match: Match) -> Text {
    if match.score.ranges.isEmpty {
      return Text(match.candidate)
        .font(.system(.body, design: .monospaced))
    }

    var attributed = AttributedString(match.candidate)
    attributed.font = .system(.body, design: .monospaced)

    for range in match.score.ranges {
      guard
        let attributedLowerBound = AttributedString.Index(range.lowerBound, within: attributed),
        let attributedUpperBound = AttributedString.Index(range.upperBound, within: attributed)
      else {
        continue
      }

      attributed[attributedLowerBound ..< attributedUpperBound].font = .system(.body, design: .monospaced).bold()
      attributed[attributedLowerBound ..< attributedUpperBound].foregroundColor = .blue
    }

    return Text(attributed)
  }

  private static let resultLimit = 300
}

#Preview {
  ContentView()
}
