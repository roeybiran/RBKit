import Foundation
import Testing

@testable import RBKit

struct FrecencyCollectionTests {

  @Test
  func `init with dictionary`() {
    let now = Date.now
    let items = ["a": FrecencyItem(id: "a", visits: [now])]
    let sut = FrecencyCollection(items: items)
    #expect(sut.items == items)
  }

  @Test
  func `init with array`() {
    let now = Date.now
    let item = FrecencyItem(id: "a", visits: [now])
    let sut = FrecencyCollection(items: [item])
    #expect(sut.items == ["a": item])
  }

  @Test
  func `add with new item`() {
    var sut = FrecencyCollection<String>()
    let item = "A"
    sut.add(entry: item)
    #expect(sut.score(for: item) == 100)
  }

  @Test
  func `add with existing item`() {
    let date = Date()
    let existingItem = FrecencyItem(id: "A", visits: [date])
    var sut = FrecencyCollection<String>(items: ["A": existingItem])
    let item = "A"
    sut.add(entry: item)
    #expect(sut.score(for: item) == 200)
  }

  @Test
  func `add with existing item having10 dates`() {
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
    #expect(sut.items.values.first?.visits.count == 10)
    #expect(sut.items.values.first?.visits.last == now)
  }

  @Test
  func `score with non existing item should return0`() {
    let sut = FrecencyCollection<String>()
    let item = "A"
    #expect(sut.score(for: item) == 0)
  }

  @Test
  func `score with last90 days`() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = try #require(Calendar.current.date(byAdding: .day, value: -90, to: now))
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 0)
  }

  @Test
  func `score with last month`() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = try #require(Calendar.current.date(byAdding: .month, value: -1, to: now))
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 10)
  }

  @Test
  func `score with last week`() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = try #require(Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now))
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 20)
  }

  @Test
  func `score with last3 days`() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = try #require(Calendar.current.date(byAdding: .day, value: -3, to: now))
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 40)
  }

  @Test
  func `score with last day`() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = try #require(Calendar.current.date(byAdding: .day, value: -1, to: now))
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 60)
  }

  @Test
  func `score with last4 hours`() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = try #require(Calendar.current.date(byAdding: .hour, value: -4, to: now))
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 80)
  }

  @Test
  func `score with now`() throws {
    let now = Date()
    var sut = FrecencyCollection<String>()
    let item = "A"
    let date = try #require(Calendar.current.date(byAdding: .hour, value: -3, to: now))
    sut.add(entry: item, timestamp: date)
    #expect(sut.score(for: item) == 100)
  }

  @Test
  func encoding() throws {
    let sut = FrecencyCollection(
      items: [
        "A": .init(
          id: "A",
          visits: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
          ],
        )
      ]
    )

    let encoded = String(data: try JSONEncoder().encode(sut), encoding: .utf8) ?? ""
    #expect(encoded.range(of: #""count":2"#) != nil)
    #expect(encoded.range(of: #""visits":[-978307200,-978307199]"#) != nil)
    #expect(encoded.range(of: #""id":"A""#) != nil)
  }

  @Test
  func decoding() throws {
    let sut = FrecencyCollection(
      items: [
        "A": .init(
          id: "A",
          visits: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
          ],
        )
      ]
    )

    let str =
      #"{"items":{"A":{"_reduced":false,"count":2,"visits":[-978307200,-978307199],"id":"A"}},"queries":{}}"#
    let decoded = try JSONDecoder().decode(
      FrecencyCollection<String>.self,
      from: str.data(using: .utf8) ?? .init(),
    )

    #expect(sut == decoded)
  }
}
