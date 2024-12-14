import Foundation

extension CGSize {
  public func clamp(to maxSize: CGSize) -> Self {
    let maxW = min(width, maxSize.width)
    let maxH = min(height, maxSize.height)
    let widthDimension = maxW / max(abs(width), 1)
    let heightDimension = maxH / max(abs(height), 1)
    let scaleFactor = min(widthDimension, heightDimension)
    let resultW = width * scaleFactor * (width < 0 ? -1 : 1)
    let resultH = height * scaleFactor * (height < 0 ? -1 : 1)
    return CGSize(width: resultW, height: resultH)
  }
}
