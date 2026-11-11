import Testing

@testable import RBKit

struct InputSourceTests {
  @Test
  func `init(id:name:) should set stored properties`() {
    let inputSource = InputSource(id: "com.example.input-source", name: "Example")

    #expect(inputSource.id == "com.example.input-source")
    #expect(inputSource.name == "Example")
  }

  @Test
  func `description should return name`() {
    let inputSource = InputSource(id: "com.example.input-source", name: "Example")

    #expect(inputSource.description == "Example")
  }
}
