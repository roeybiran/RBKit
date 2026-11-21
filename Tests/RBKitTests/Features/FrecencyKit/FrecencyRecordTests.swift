import Foundation
import Testing

@testable import RBKit

// MARK: - BadCalendar

final class BadCalendar: NSCalendar {
  override func date(byAdding _: DateComponents, to _: Date, options _: NSCalendar.Options = [])
    -> Date?
  {
    nil
  }
}

// MARK: - FrecencyRecordTests

struct FrecencyRecordTests {

  @Test
  func `item init`() {
    let dates = [Date(timeIntervalSinceReferenceDate: 0), Date(timeIntervalSinceReferenceDate: 1)]
    let a = FrecencyRecord(
      visits: dates,
      count: 4,
    )
    #expect(4 == a.count)
    #expect(dates == a.visits)
  }

  @Test
  func `item init2`() {
    let dates = [Date(timeIntervalSinceReferenceDate: 0), Date(timeIntervalSinceReferenceDate: 1)]
    let a = FrecencyRecord(
      visits: dates,
      count: dates.count,
    )
    #expect(2 == a.count)
    #expect(dates == a.visits)
  }

  @Test
  func `score returns0 when calendar cannot calculate boundaries`() throws {
    let item = FrecencyRecord(visits: [Date.now], count: 1)
    let calendar = try #require(BadCalendar(calendarIdentifier: .gregorian)) as Calendar

    #expect(item.score(in: calendar) == 0)
  }
}
