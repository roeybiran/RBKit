import Testing

@testable import RBKit

@Suite
struct `Sequence Extensions Tests` {
    @Test
    func `Sorted by key path returns ascending order`() {
        struct Book: Equatable {
            let id: Int
            let kind: String
        }

        let values = [Book(id: 1, kind: "Book"), Book(id: 0, kind: "Library")]
        let sorted = values.sorted(by: \.id)

        #expect(sorted == values.reversed())
    }

    @Test
    func `Dictionary grouping produces buckets`() {
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
    func `Set converts to array`() {
        let set = Set<String>()

        #expect(set.toArray() == [String]())
    }

    @Test
    func `Array converts to set`() {
        let values = ["a", "a"]

        #expect(values.toSet() == Set(["a"]))
    }
}
