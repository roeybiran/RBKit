import Dependencies
import Foundation
import RBKit
import SwiftUI

struct FuzzyMatcherDemo: View {
  struct Match: Identifiable {
    let candidate: String
    let score: FzyJS.Rank

    var id: String {
      candidate
    }
  }

  @Dependency(\.fuzzyMatcher) private var fuzzyMatcher

  @State private var query = ""
  @State private var lines = [String]()
  @State private var matches = [Match]()

  var body: some View {
    Section("Fuzzy Matcher") {
      TextField("Query", text: $query)
      List(matches) { match in
        LazyVStack(alignment: .leading) {
          Text(highlightedText(match.candidate, positions: match.score.positions)).lineLimit(1)
        }
      }
    }
    .onAppear {
      lines = Self.loadLines()
    }
    .task(id: query) {
      matches = await updateMatches(query: query, lines: lines)
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
}
