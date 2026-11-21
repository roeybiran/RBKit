import Foundation
import Testing

@testable import RBKit

struct FrecencyCollectionTests {

  @Test
  func `init with dictionary`() {
    let now = Date.now
    let items = ["a": FrecencyRecord(visits: [now], count: 1)]
    let sut = FrecencyCollection(items: items)

    #expect(sut.items == items)
  }

  @Test
  func `add with new item`() {
    var sut = FrecencyCollection<String>()

    sut.add(entry: "A")

    #expect(sut.score(for: "A") == 100)
  }

  @Test
  func `add with existing item`() {
    let date = Date()
    let existingItem = FrecencyRecord(visits: [date], count: 1)
    var sut = FrecencyCollection(items: ["A": existingItem])

    sut.add(entry: "A")

    #expect(sut.score(for: "A") == 200)
  }

  @Test
  func `add with existing item having10 dates`() {
    let dates: [Date] = Array(repeating: 0, count: 10)
      .enumerated()
      .map { idx, _ in .distantPast.addingTimeInterval(Double(idx)) }
    let existingItem = FrecencyRecord(visits: dates, count: dates.count)
    let now = Date.now
    var sut = FrecencyCollection(items: ["A": existingItem])

    sut.add(entry: "A", timestamp: now)

    #expect(sut.score(for: "A") == 110)
    #expect(sut.items.count == 1)
    #expect(sut.items.values.first?.visits.count == 10)
    #expect(sut.items.values.first?.visits.last == now)
  }

  @Test
  func `score with non existing item should return0`() {
    let sut = FrecencyCollection<String>()

    #expect(sut.score(for: "A") == 0)
  }

  @Test
  func `score with last90 days`() throws {
    let now = Date()
    let date = try #require(Calendar.current.date(byAdding: .day, value: -90, to: now))
    var sut = FrecencyCollection<String>()

    sut.add(entry: "A", timestamp: date)

    #expect(sut.score(for: "A") == 0)
  }

  @Test
  func `score with last month`() throws {
    let now = Date()
    let date = try #require(Calendar.current.date(byAdding: .month, value: -1, to: now))
    var sut = FrecencyCollection<String>()

    sut.add(entry: "A", timestamp: date)

    #expect(sut.score(for: "A") == 10)
  }

  @Test
  func `score with last week`() throws {
    let now = Date()
    let date = try #require(Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now))
    var sut = FrecencyCollection<String>()

    sut.add(entry: "A", timestamp: date)

    #expect(sut.score(for: "A") == 20)
  }

  @Test
  func `score with last3 days`() throws {
    let now = Date()
    let date = try #require(Calendar.current.date(byAdding: .day, value: -3, to: now))
    var sut = FrecencyCollection<String>()

    sut.add(entry: "A", timestamp: date)

    #expect(sut.score(for: "A") == 40)
  }

  @Test
  func `score with last day`() throws {
    let now = Date()
    let date = try #require(Calendar.current.date(byAdding: .day, value: -1, to: now))
    var sut = FrecencyCollection<String>()

    sut.add(entry: "A", timestamp: date)

    #expect(sut.score(for: "A") == 60)
  }

  @Test
  func `score with last4 hours`() throws {
    let now = Date()
    let date = try #require(Calendar.current.date(byAdding: .hour, value: -4, to: now))
    var sut = FrecencyCollection<String>()

    sut.add(entry: "A", timestamp: date)

    #expect(sut.score(for: "A") == 80)
  }

  @Test
  func `score with now`() throws {
    let now = Date()
    let date = try #require(Calendar.current.date(byAdding: .hour, value: -3, to: now))
    var sut = FrecencyCollection<String>()

    sut.add(entry: "A", timestamp: date)

    #expect(sut.score(for: "A") == 100)
  }

  @Test
  func encoding() throws {
    let sut = FrecencyCollection(
      items: [
        "A": .init(
          visits: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
          ],
          count: 2,
        )
      ]
    )

    let encoded = String(data: try JSONEncoder().encode(sut), encoding: .utf8) ?? ""
    #expect(encoded.range(of: #""count":2"#) != nil)
    #expect(encoded.range(of: #""visits":[-978307200,-978307199]"#) != nil)
    #expect(encoded.range(of: #""id":"A""#) == nil)
  }

  @Test
  func decoding() throws {
    let sut = FrecencyCollection(
      items: [
        "A": .init(
          visits: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
          ],
          count: 2,
        )
      ]
    )

    let str =
      #"{"items":{"A":{"count":2,"visits":[-978307200,-978307199],"id":"A"}},"queries":{}}"#
    let decoded = try JSONDecoder().decode(
      FrecencyCollection<String>.self,
      from: str.data(using: .utf8) ?? .init(),
    )

    #expect(sut == decoded)
  }

  @Test
  func `old record payload with id still decodes`() throws {
    let record = try JSONDecoder().decode(
      FrecencyRecord.self,
      from: #"{"count":2,"visits":[-978307200,-978307199],"id":"A"}"#.data(using: .utf8) ?? .init(),
    )

    #expect(
      record == FrecencyRecord(
        visits: [
          Date(timeIntervalSince1970: 0),
          Date(timeIntervalSince1970: 1),
        ],
        count: 2,
      )
    )
  }
}
