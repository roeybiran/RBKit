import Carbon

class Box {
  var eventHandler: (_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent) -> Unmanaged<CGEvent>? = { _, _, _ in nil }
}