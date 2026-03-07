import Foundation
import Testing

@testable import RBKit

@Suite
struct `CGSize Tests` {
  @Test
  func `clamp, with smaller size, should keep original size`() {
    let original = CGSize(width: 100, height: 50)
    let maximum = CGSize(width: 200, height: 100)

    let clamped = original.clamp(to: maximum)

    #expect(clamped == CGSize(width: 100, height: 50))
  }

  @Test
  func `clamp, with oversized dimensions, should trim to maximum`() {
    let original = CGSize(width: 400, height: 300)
    let maximum = CGSize(width: 200, height: 150)

    let clamped = original.clamp(to: maximum)

    #expect(clamped == CGSize(width: 200, height: 150))
  }

  @Test
  func `clamp, with oversized size, should preserve aspect ratio`() {
    let original = CGSize(width: 400, height: 200)
    let maximum = CGSize(width: 200, height: 200)

    let clamped = original.clamp(to: maximum)

    #expect(clamped == CGSize(width: 200, height: 100))
  }

  @Test
  func `clamp, with zero dimensions, should remain zero`() {
    let original = CGSize(width: 0, height: 0)
    let maximum = CGSize(width: 200, height: 200)

    let clamped = original.clamp(to: maximum)

    #expect(clamped == CGSize(width: 0, height: 0))
  }

  @Test
  func `clamp, with negative dimensions, should remain unchanged`() {
    let original = CGSize(width: -100, height: -50)
    let maximum = CGSize(width: 200, height: 200)

    let clamped = original.clamp(to: maximum)

    #expect(clamped == CGSize(width: -100, height: -50))
  }
}
