import Foundation
import Testing

@testable import RBKit

struct FrecencyCollectionTests {

  // MARK: Internal

  @Test func initWithDictionary() throws {
    let now = Date.now
    let items = ["a": FrecencyItem(id: "a", visits: [now])]
    let sut = FrecencyCollection(items: items)
    #expect(sut.items == items)
  }

  @Test func initWithArray() throws {
    let now = Date.now
    let item = FrecencyItem(id: "a", visits: [now])
    let sut = FrecencyCollection(items: [item])
    #expect(sut.items == ["a": item])
  }

  @Test func add_withNewItem() throws {
    var sut = FrecencyCollection<String>()
    let item = "A"
    sut.add(entry: item)
    #expect(sut.score(for: item) == 100)
  }

  @Test func add_withExistingItem() throws {
    let date = Date()
    let existingItem = FrecencyItem(id: "A", visits: [date])
    var sut = FrecencyCollection<String>(items: ["A": existingItem])
    let item = "A"
    sut.add(entry: item)
    #expect(sut.score(for: item) == 200)
  }

  @Test func add_withExistingItemHaving10Dates() throws {
    let dates: [Date] = Array(repeating: 0, count: 10)
      .enumerated()
      .map { idx, _ in .distantPast.addingTimeInterval(Double(idx)) }

    let existingItem = FrecencyItem(id: "A", visits: dates)
    var sut = FrecencyCollection<String>(items: ["A": existingItem])
    let item = "A"
    let now = Date.now
    sut.add(entry: item, timestamp: now)
    #expect(sut.score(for: item) == 110)
    #expect(sut.items.count == 1)
    #expect(sut.items.values.first!.visits.count == 10)
    #expect(sut.items.values.first!.visits.last! == now)
  }

  @Test func score_withNonExistingItem_shouldReturn0() throws {
    let sut = FrecencyCollection<String>()
    let item = "A"
    #expect(sut.score(for: item) == 0)
  }

  @Test func score_withLast90Days() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = Calendar.current.date(byAdding: .day, value: -90, to: now)!
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 0)
  }

  @Test func score_withLastMonth() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = Calendar.current.date(byAdding: .month, value: -1, to: now)!
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 10)
  }

  @Test func score_withLastWeek() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now)!
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 20)
  }

  @Test func score_withLast3Days() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = Calendar.current.date(byAdding: .day, value: -3, to: now)!
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 40)
  }

  @Test func score_withLastDay() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = Calendar.current.date(byAdding: .day, value: -1, to: now)!
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 60)
  }

  @Test func score_withLast4Hours() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = Calendar.current.date(byAdding: .hour, value: -4, to: now)!
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 80)
  }

  @Test func score_withNow() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = Calendar.current.date(byAdding: .hour, value: -3, to: now)!
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 100)
  }

  @Test func encoding() throws {
    let sut = FrecencyCollection(
      items: [
        "A": .init(
          id: "A",
          visits: [
            Date.init(timeIntervalSince1970: 0),
            Date.init(timeIntervalSince1970: 1),
          ]
        )
      ]
    )

    let encoded = String(data: try JSONEncoder().encode(sut), encoding: .utf8) ?? ""
    #expect(encoded.range(of: #""count":2"#) != nil)
    #expect(encoded.range(of: #""visits":[-978307200,-978307199]"#) != nil)
    #expect(encoded.range(of: #""id":"A""#) != nil)

  }
  @Test func decoding() throws {
    let sut = FrecencyCollection(
      items: [
        "A": .init(
          id: "A",
          visits: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
          ]
        )
      ]
    )

    let str =
      #"{"items":{"A":{"_reduced":false,"count":2,"visits":[-978307200,-978307199],"id":"A"}},"queries":{}}"#
    let decoded = try JSONDecoder().decode(
      FrecencyCollection<String>.self, from: str.data(using: .utf8) ?? .init())

    #expect(sut == decoded)
  }
}
