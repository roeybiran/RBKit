import Testing

@testable import RBKit

@Test @MainActor
func `OperationButton, should update appearance from status`() {
  let sut = OperationButton(idleTitle: "idle")

  sut.status = .init(.busy, title: "busy")
  #expect(sut.title == "busy")
  #expect(sut.isEnabled == false)
  #expect(sut.image == nil)
  #expect(sut.bezelColor == nil)

  sut.status = .init(.success, title: "ok")
  #expect(sut.title == "ok")
  #expect(sut.isEnabled == false)
  #expect(sut.image == OperationButton.successImage)
  #expect(sut.bezelColor == .systemGreen)

  sut.status = .init(.error, title: "err")
  #expect(sut.title == "err")
  #expect(sut.isEnabled == true)
  #expect(sut.image == OperationButton.errorImage)
  #expect(sut.bezelColor == .systemRed)

  sut.status = nil
  #expect(sut.title == "idle")
  #expect(sut.isEnabled == true)
  #expect(sut.image == nil)
  #expect(sut.bezelColor == nil)
}
