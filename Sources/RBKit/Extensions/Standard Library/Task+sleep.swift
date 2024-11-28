extension Task<Never, Never> {
  @available(macOS, deprecated: 13.0)
  public static func sleep(forSeconds seconds: Double) async throws {
    if #available(macOS 13.0, *) {
      try await Task.sleep(for: .seconds(seconds))
    } else {
      try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
  }
}
