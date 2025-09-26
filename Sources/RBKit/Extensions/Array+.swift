extension Array {
    public subscript(safe index: Index) -> Element? {
        get {
          startIndex <= index && index < endIndex ? self[index] : nil
        }
        set {
            if startIndex <= index, index < endIndex, let newValue {
                self[index] = newValue
            }
        }
    }
}
