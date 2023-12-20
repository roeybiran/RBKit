import Dependencies
import DependenciesMacros
import Foundation

// MARK: - UserDefaultsClient

@DependencyClient
public struct UserDefaultsClient {
  public var object: (_ forKey: String) -> Any?
  public var url: (_ forKey: String) -> URL?
  public var array: (_ forKey: String) -> [Any]?
  public var dictionary: (_ forKey: String) -> [String: Any]?
  public var string: (_ forKey: String) -> String?
  public var stringArray: (_ forKey: String) -> [String]?
  public var data: (_ forKey: String) -> Data?
  public var bool: (_ forKey: String) -> Bool = { _ in false }
  public var integer: (_ forKey: String) -> Int = { _ in 0 }
  public var float: (_ forKey: String) -> Float = { _ in 0 }
  public var double: (_ forKey: String) -> Double = { _ in 0 }

  public var setAny: (_ value: Any?, _ defaultName: String) -> Void
  public var setFloat: (_ value: Float, _ defaultName: String) -> Void
  public var setDouble: (_ value: Double, _ defaultName: String) -> Void
  public var setInt: (_ value: Int, _ defaultName: String) -> Void
  public var setBool: (_ value: Bool, _ defaultName: String) -> Void
  public var setURL: (_ value: URL?, _ defaultName: String) -> Void

  public var removeObject: (_ defaultName: String) -> Void
  public var register: (_ registrationDictionary: [String: Any]) -> Void
}

// MARK: DependencyKey

extension UserDefaultsClient: DependencyKey {
  public static let liveValue: Self = {
    let suite = UserDefaults.standard
    return Self(
      object: suite.object(forKey:),
      url: suite.url(forKey:),
      array: suite.array(forKey:),
      dictionary: suite.dictionary(forKey:),
      string: suite.string(forKey:),
      stringArray: suite.stringArray(forKey:),
      data: suite.data(forKey:),
      bool: suite.bool(forKey:),
      integer: suite.integer(forKey:),
      float: suite.float(forKey:),
      double: suite.double(forKey:),
      setAny: suite.set(_:forKey:),
      setFloat: suite.set(_:forKey:),
      setDouble: suite.set(_:forKey:),
      setInt: suite.set(_:forKey:),
      setBool: suite.set(_:forKey:),
      setURL: suite.set(_:forKey:),
      removeObject: suite.removeObject(forKey:),
      register: suite.register(defaults:))
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var userDefaultsClient: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}
