import RBKit
import Testing

struct EventTypeTests {
  @Test
  func `public initializer should create repeated key down events`() {
    let event = EventType(kind: .keyDown, isRepeat: true)

    #expect(event.kind == .keyDown)
    #expect(event.isRepeat)
  }

  @Test
  func `public initializer should default to non-repeated events`() {
    #expect(EventType(kind: .keyUp) == .keyUp)
  }
}
