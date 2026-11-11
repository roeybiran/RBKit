import AppKit

public final class CountdownProgressIndicator: NSProgressIndicator {

  // MARK: Lifecycle

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    isIndeterminate = false
    style = .spinning
    doubleValue = initialValue
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    timerTask?.cancel()
  }

  // MARK: Public

  public override func draw(_ dirtyRect: NSRect) {
    controlSize = dirtyRect.width <= 24 ? .mini : .regular
    super.draw(dirtyRect)
  }

  // MARK: Internal

  var duration = 0.5

  var isAnimating = false {
    didSet {
      NSAnimationContext.current.timingFunction = .init(name: .easeInEaseOut)
      if isAnimating {
        doubleValue = initialValue // reset back to initial state
        timerTask?.cancel()
        timerTask = Task { [weak self] in
          do {
            for _ in 0..<(self?.interval ?? 0) {
              guard let self else { return }
              try await Task.sleep(for: .seconds(tick))
              animator().doubleValue -= initialValue / Double(interval)
            }
          } catch {
            self?.animator().doubleValue = self?.initialValue ?? 0
          }
        }
      } else {
        timerTask?.cancel()
      }
    }
  }

  // MARK: Private

  private lazy var interval = Int(Double(duration) / tick)
  private let initialValue = 100.0
  private var timerTask: Task<Void, Never>?
  private let tick = 0.1
}
