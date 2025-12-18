import Foundation
import Testing

@testable import RBKit

struct FrecencyItemTests {

  // MARK: Internal

  @Test func item_init() throws {
    let dates = [Date(timeIntervalSinceReferenceDate: 0), Date(timeIntervalSinceReferenceDate: 1)]
    let a = FrecencyItem<String>(
      id: "a",
      visits: dates,
      count: 4
    )
    #expect("a" == a.id)
    #expect(4 == a.count)
    #expect(dates == a.visits)
    #expect(false == a._reduced)
  }

  @Test func item_init2() throws {
    let dates = [Date(timeIntervalSinceReferenceDate: 0), Date(timeIntervalSinceReferenceDate: 1)]
    let a = FrecencyItem<String>(
      id: "a",
      visits: dates
    )
    #expect("a" == a.id)
    #expect(2 == a.count)
    #expect(dates == a.visits)
    #expect(false == a._reduced)
  }

  @Test func debugDescription() throws {
    let a = FrecencyItem<String>(
      id: "a",
      visits: [Date(timeIntervalSinceReferenceDate: 0), Date(timeIntervalSinceReferenceDate: 1)]
    )
    #expect(
      a.debugDescription
        == "ID: a, SCORE: 0.0, COUNT: 2, VISITS: [2001-01-01 00:00:00 +0000, 2001-01-01 00:00:01 +0000]})"
    )
  }
}
