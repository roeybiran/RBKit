import Foundation
import Testing
@testable import RBKit

@Suite
struct CGSizeClampTests {
  @Test
  func clampSmallerSize() {
    let originalSize = CGSize(width: 100, height: 50)
    let maxSize = CGSize(width: 200, height: 100)

    let clampedSize = originalSize.clamp(to: maxSize)

    #expect(clampedSize.width == 100)
    #expect(clampedSize.height == 50)
  }

  @Test
  func clampLargerSize() {
    let originalSize = CGSize(width: 400, height: 300)
    let maxSize = CGSize(width: 200, height: 150)

    let clampedSize = originalSize.clamp(to: maxSize)

    #expect(clampedSize.width == 200)
    #expect(clampedSize.height == 150)
  }

  @Test
  func clampWithAspectRatioMaintained() {
    let originalSize = CGSize(width: 400, height: 200)
    let maxSize = CGSize(width: 200, height: 200)

    let clampedSize = originalSize.clamp(to: maxSize)

    #expect(clampedSize.width == 200)
    #expect(clampedSize.height == 100)
  }

  @Test
  func clampWithZeroDimensions() {
    let originalSize = CGSize(width: 0, height: 0)
    let maxSize = CGSize(width: 200, height: 200)

    let clampedSize = originalSize.clamp(to: maxSize)

    #expect(clampedSize.width == 0)
    #expect(clampedSize.height == 0)
  }

  @Test
  func clampWithNegativeDimensions() {
    let originalSize = CGSize(width: -100, height: -50)
    let maxSize = CGSize(width: 200, height: 200)

    let clampedSize = originalSize.clamp(to: maxSize)

    #expect(clampedSize.width == -100)
    #expect(clampedSize.height == -50)
  }
}
