import XCTest
@testable import RBKit

final class FuzzyMatcherTests: XCTestCase {

  func test_sanity() throws {
    let score = "Sort By".rank(for: "sby")

    XCTAssertEqual(score.rank, 0.5233516483516484)
    XCTAssertEqual(score.ranges[0].lowerBound, 0)
    XCTAssertEqual(score.ranges[0].upperBound, 1)
    XCTAssertEqual(score.ranges[1].lowerBound, 5)
    XCTAssertEqual(score.ranges[1].upperBound, 7)
  }

  func test_sanity_2() throws {
    let result = ["OakTabBarView.mm", "OakTabBarView.h", "OakTextView.mm", "OakTextView.h"].map { $0.rank(for: "obtv") }
      .filter { $0.rank > 0 }
    XCTAssertEqual(result.count, 0)
  }

  func test_subset() throws {
    let score = "ezdziztzozr".rank(for: "editor")
    XCTAssertGreaterThan(score.rank, 0)
  }

  func test_not_subset() throws {
    let score = "oaktextview.mm".rank(for: "obtv")
    XCTAssertEqual(score.rank, 0)
  }

  func test_prefix() throws {
    let score = "oaktextview.mm".rank(for: "oak")
    XCTAssertGreaterThan(score.rank, 0)
  }

  func test_suffix() throws {
    let score = "oaktextview.mm".rank(for: "w.mm")
    XCTAssertGreaterThan(score.rank, 0)
  }

  func test_filterLongerThanHaystack() throws {
    let score = "obtv".rank(for: "oaktextview.mm")
    XCTAssertEqual(score.rank, 0)
    XCTAssertEqual(score.ranges, [])
  }

  // the following tests are a port of https://github.com/textmate/textmate/blob/master/Frameworks/text/tests/t_ranker.cc at commit hash c239748

  func test_capitalCoverage() {
    XCTAssertLessThan(
      "OTVStatusBar.mm".rank(for: "otv"),
      "OakTextView.mm".rank(for: "otv")
    )
  }

  func test_distanceToStart() {
    XCTAssertLessThan(
      "OakDocument.mm".rank(for: "doc"),
      "document.cc".rank(for: "doc")
    )
  }

  func test_substring() {
    XCTAssertLessThan(
      "Encrypt With Password — Text".rank(for: "paste"),
      "Paste Selection Online — TextMate".rank(for: "paste")
    )
  }

  func test_fullMatch() {
    XCTAssertLessThan(
      "RMateServer.cc".rank(for: "rmate"),
      "rmate".rank(for: "rmate")
    )
  }

  func test_ranker() {
    let files = ["OakTabBarView.mm", "OakTabBarView.h", "OakTextView.mm", "OakTextView.h"]
      .map { $0.rank(for: "otbv") }
      .filter { $0.rank > 0 }

    XCTAssertEqual(files.count, 2)
  }

  func test_ranker_1() {
    XCTAssertNotEqual(
      "OakFileChooser".rank(for: "oakfilechooser").rank,
      0
    )

    XCTAssertNotEqual(
      "OakFinderLabelChooser".rank(for: "oakfilechooser").rank,
      0
    )

    XCTAssertLessThan(
      "OakFinderLabelChooser".rank(for: "oakfilechooser").rank,
      "OakFileChooser".rank(for: "oakfilechooser").rank
    )
  }

  func test_ranker_2() {
    XCTAssertNotEqual(
      "Comments » Insert Comment Banner — Source".rank(for: "banne").rank,
      0
    )

    XCTAssertNotEqual(
      "Comments » Insert Comment Banner — Source".rank(for: "banner").rank,
      0
    )
  }

  func test_normalizeFilter() {
    XCTAssertEqual("t d l".normalized(), "tdl")
    XCTAssertEqual("td l".normalized(), "tdl")
    XCTAssertEqual("TDL".normalized(), "tdl")
    XCTAssertEqual("TD L".normalized(), "tdl")
    XCTAssertEqual("TD l".normalized(), "tdl")
  }

  func test_highlightRange() {
    let score = "HTMLOutput.h".rank(for: "HTo")
    XCTAssertLessThan(0.0, score.rank)
    XCTAssertLessThan(score.rank, 1.0)
    XCTAssertEqual(score.ranges.count, 2)
    XCTAssertEqual(score.ranges[0].lowerBound, 0)
    XCTAssertEqual(score.ranges[0].upperBound, 2)
    XCTAssertEqual(score.ranges[1].lowerBound, 4)
    XCTAssertEqual(score.ranges[1].upperBound, 5)
  }
}
