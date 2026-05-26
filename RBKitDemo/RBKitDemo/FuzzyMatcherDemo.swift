import Dependencies
import Foundation
import RBKit
import SwiftUI

struct FuzzyMatcherDemo: View {
  struct Match: Identifiable {
    let candidate: String
    let score: Double
    let ranges: [Range<String.Index>]

    var id: String {
      candidate
    }
  }

  @Dependency(\.fzyJS) private var fzyJS

  @State private var query = ""
  @State private var lines = [String]()
  @State private var matches = [Match]()

  var body: some View {
    Section("Fuzzy Matcher") {
      TextField("Query", text: $query)
      List(matches) { match in
        LazyVStack(alignment: .leading) {
          Text(highlightedText(match.candidate, ranges: match.ranges)).lineLimit(1)
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
        Match(candidate: $0, score: 0, ranges: [])
      }
    } else {
      for candidate in lines {
        let score = await fzyJS.score(trimmedQuery.normalized(), candidate)

        if score <= 0 {
          continue
        }

        let ranges = await fzyJS.ranges(trimmedQuery.normalized(), candidate)
        matches.append(Match(candidate: candidate, score: score, ranges: ranges))
      }
      matches.sort { lhs, rhs in
        lhs.score > rhs.score
      }
    }
    return matches
  }

  private func highlightedText(_ string: String, ranges: [Range<String.Index>]) -> AttributedString {
    var attributed = AttributedString(string)
    attributed.font = .system(.body, design: .monospaced)

    for range in ranges {
      guard
        let attributedLowerBound = AttributedString.Index(range.lowerBound, within: attributed),
        let attributedUpperBound = AttributedString.Index(range.upperBound, within: attributed)
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
