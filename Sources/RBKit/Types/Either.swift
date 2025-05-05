// MARK: - Either

public enum Either<Left, Right> {
  case left(Left)
  case right(Right)
}

// MARK: Equatable

extension Either: Equatable where Left: Equatable, Right: Equatable { }
