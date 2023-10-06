import Foundation
import Dependencies

public struct UserDefaultsClient {
  public var getObject: (_ keyName: String) -> Any?
  public var getUrl: (_ keyName: String) -> URL?
  public var getArray: (_ keyName: String) -> [Any]?
  public var getDictionary: (_ keyName: String) -> [String: Any]?
  public var getString: (_ keyName: String) -> String?
  public var getStringArray: (_ keyName: String) -> [String]?
  public var getData: (_ keyName: String) -> Data?
  public var getBool: (_ keyName: String) -> Bool
  public var getInteger: (_ keyName: String) -> Int
  public var getFloat: (_ keyName: String) -> Float
  public var getDouble: (_ keyName: String) -> Double

  public var setAny: (_ value: Any?, _ keyName: String) -> Void
  public var setFloat: (_ value: Float, _ keyName: String) -> Void
  public var setDouble: (_ value: Double, _ keyName: String) -> Void
  public var setInt: (_ value: Int, _ keyName: String) -> Void
  public var setBool: (_ value: Bool, _ keyName: String) -> Void
  public var setURL: (_ value: URL?, _ keyName: String) -> Void

  public var removeObject: (_ keyName: String) -> Void
  public var registerDefaults: ([String: Any]) -> Void
}

extension UserDefaultsClient: DependencyKey {
  public static let liveValue: Self = {
    let suite = UserDefaults.standard
    return Self(
      getObject: suite.object(forKey:),
      getUrl: suite.url(forKey:),
      getArray: suite.array(forKey:),
      getDictionary: suite.dictionary(forKey:),
      getString: suite.string(forKey:),
      getStringArray: suite.stringArray(forKey:),
      getData: suite.data(forKey:),
      getBool: suite.bool(forKey:),
      getInteger: suite.integer(forKey:),
      getFloat: suite.float(forKey:),
      getDouble: suite.double(forKey:),
      setAny: suite.set(_:forKey:),
      setFloat: suite.set(_:forKey:),
      setDouble: suite.set(_:forKey:),
      setInt: suite.set(_:forKey:),
      setBool: suite.set(_:forKey:),
      setURL: suite.set(_:forKey:),
      removeObject: suite.removeObject(forKey:),
      registerDefaults: suite.register(defaults:))
  }()

#if DEBUG
  public static let testValue = Self(
    getObject: { _ in unimplemented("getObject", placeholder: nil) },
    getUrl: { _ in unimplemented("getUrl", placeholder: nil) },
    getArray: { _ in unimplemented("getArray", placeholder: nil) },
    getDictionary: { _ in unimplemented("getDictionary", placeholder: nil) },
    getString: { _ in unimplemented("getString", placeholder: nil) },
    getStringArray: { _ in unimplemented("getStringArray", placeholder: nil) },
    getData: { _ in unimplemented("getData", placeholder: nil) },
    getBool: { _ in unimplemented("getBool", placeholder: false) },
    getInteger: { _ in unimplemented("getInteger", placeholder: 0) },
    getFloat: { _ in unimplemented("getFloat", placeholder: 0) },
    getDouble: { _ in unimplemented("getDouble", placeholder: 0) },
    setAny: { _, _ in unimplemented("setAny") },
    setFloat: { _, _ in unimplemented("setFloat") },
    setDouble: { _, _ in unimplemented("setDouble") },
    setInt: { _, _ in unimplemented("setInt") },
    setBool: { _, _ in unimplemented("setBool") },
    setURL: { _, _ in unimplemented("setURL") },
    removeObject: { _ in unimplemented("removeObject") },
    registerDefaults: { _ in unimplemented("registerDefaults") })
#endif

}

extension DependencyValues {
  public var userDefaultsClient: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}
