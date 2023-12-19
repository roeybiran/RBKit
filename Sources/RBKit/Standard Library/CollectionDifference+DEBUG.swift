#if DEBUG
extension CollectionDifference: CustomDebugStringConvertible {
  public var debugDescription: String {
    isEmpty ? 
    "<NO DIFFERENCES>"
    : """
    removals:
      \(removals.enumerated().map { "\($0)) \($1)" }.joined(separator: "\n") )
    insertions:
      \(insertions.enumerated().map { "\($0)) \($1)" }.joined(separator: "\n") )
    """
  }
}
#endif
