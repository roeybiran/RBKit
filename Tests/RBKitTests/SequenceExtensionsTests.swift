import Testing

@testable import RBKit

@Suite
struct `Sequence Tests` {
    @Test
    func `sorted by:, with keyPath, should return ascending order`() async throws {
        struct Book: Equatable {
            let id: Int
            let kind: String
        }

        let values = [Book(id: 1, kind: "Book"), Book(id: 0, kind: "Library")]
        let sorted = values.sorted(by: \.id)

        #expect(sorted == values.reversed())
    }

    @Test
    func `dictionary groupingBy:, should produce buckets`() async throws {
        struct Book: Equatable {
            let name: String
            let kind: String
        }

        let values = [
            Book(name: "a", kind: "Book"),
            Book(name: "b", kind: "Library"),
        ]
        let grouped = values.dictionary(groupingBy: { $0.kind })

        #expect(grouped == ["Book": [values[0]], "Library": [values[1]]])
    }

    @Test
    func `toArray, with Set, should convert to array`() async throws {
        let set = Set<String>()

        #expect(set.toArray() == [String]())
    }

    @Test
    func `toSet, with Array, should convert to set`() async throws {
        let values = ["a", "a"]

        #expect(values.toSet() == Set(["a"]))
    }
}
