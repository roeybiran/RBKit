import Testing
@testable import RBKit

struct HotKeyErrorTests {
  @Test
  func `description, with carbonHotKeyExists, should match the user-facing copy`() {
    #expect(
      HotKeyManagerError.carbonHotKeyExists.description
        == "This keyboard shortcut is already in use by another application."
    )
  }

  @Test
  func `description, with userConflict, should match the user-facing copy`() {
    #expect(
      HotKeyManagerError.userConflict.description
        == "The chosen keyboard shortcut conflicts with an existing one."
    )
  }

  @Test
  func `description, with unknown, should match the user-facing copy`() {
    #expect(HotKeyManagerError.unknown.description == "Something went wrong.")
  }
}
