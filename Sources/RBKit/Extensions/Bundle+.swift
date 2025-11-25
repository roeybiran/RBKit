import Foundation

extension Bundle {
  public var appName: String {
    object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? "App"
  }
}
