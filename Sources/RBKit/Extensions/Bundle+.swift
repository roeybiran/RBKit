import Foundation

extension Bundle {
  // Can be used by packages to refer the consuming app's name
  public var appName: String {
    object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? "App"
  }
}
