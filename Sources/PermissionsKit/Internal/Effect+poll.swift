import ComposableArchitecture
import Foundation

extension Effect {
  static func poll(
    for duration: Duration,
    until condition: @escaping @Sendable () -> Bool,
    emit action: @escaping @autoclosure @Sendable () -> Action,
    id: any Hashable & Sendable,
    clock: any Clock<Duration>,
  ) -> Effect<Action> {
    .run { send in
      for await _ in clock.timer(interval: duration) {
        let conditionMet = condition()
        if conditionMet {
          await send(action())
          break
        }
      }
    }
    .cancellable(id: id)
  }
}
