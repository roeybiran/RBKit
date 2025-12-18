import Foundation

public struct FrecencyItem<ID: FrecencyID>: Hashable, Codable, Sendable {
  public let id: ID
  public var visits: [Date]
  public var count: Int
  var _reduced = false

  public func score(referencing date: Date = .now, in calendar: Calendar = .current) -> Double {
    let score = visits.map { self.score(for: $0, referenceDate: date, referenceCalendar: calendar) }
      .reduce(into: 0, +=)
    return Double(count) * score / Double(visits.count)
  }

  public init(id: ID, visits: [Date], count: Int) {
    self.id = id
    self.visits = visits
    self.count = count
  }

  private func score(for targetDate: Date, referenceDate: Date, referenceCalendar: Calendar)
    -> Double
  {
    guard
      let last4Hours = referenceCalendar.date(byAdding: .hour, value: -4, to: referenceDate),
      let lastDay = referenceCalendar.date(byAdding: .day, value: -1, to: referenceDate),
      let last3Days = referenceCalendar.date(byAdding: .day, value: -3, to: referenceDate),
      let lastWeek = referenceCalendar.date(byAdding: .weekOfYear, value: -1, to: referenceDate),
      let lastMonth = referenceCalendar.date(byAdding: .month, value: -1, to: referenceDate),
      let last90Days = referenceCalendar.date(byAdding: .day, value: -90, to: referenceDate)
    else {
      return 0
    }

    switch targetDate {
    case ..<last90Days:
      return 0
    case ..<lastMonth:
      return 10
    case ..<lastWeek:
      return 20
    case ..<last3Days:
      return 40
    case ..<lastDay:
      return 60
    case ..<last4Hours:
      return 80
    default:
      return 100
    }
  }

}

extension FrecencyItem {
  public init(id: ID, visits: [Date] = []) {
    self.id = id
    self.visits = visits
    self.count = visits.count
    self._reduced = false
  }
}

#if DEBUG
  extension FrecencyItem: CustomDebugStringConvertible {
    public var debugDescription: String {
      "ID: \(id), SCORE: \(score()), COUNT: \(count), VISITS: \(visits)})"
    }
  }
#endif
