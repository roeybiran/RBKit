import Dependencies
import DependenciesMacros
import Foundation

// MARK: - UserDefaultsClient

@DependencyClient
public struct UserDefaultsClient: Sendable {

  public typealias Stream<T> = AsyncStream<(object: UserDefaults, change: NSKeyValueObservedChange<T>)>

  public static nonisolated(unsafe) var suite = UserDefaults.standard

  public var object: @Sendable (_ forKey: String) -> Any?
  public var url: @Sendable (_ forKey: String) -> URL?
  public var array: @Sendable (_ forKey: String) -> [Any]?
  public var dictionary: @Sendable (_ forKey: String) -> [String: Any]?
  public var string: @Sendable (_ forKey: String) -> String?
  public var stringArray: @Sendable (_ forKey: String) -> [String]?
  public var data: @Sendable (_ forKey: String) -> Data?
  public var bool: @Sendable (_ forKey: String) -> Bool = { _ in false }
  public var integer: @Sendable (_ forKey: String) -> Int = { _ in 0 }
  public var float: @Sendable (_ forKey: String) -> Float = { _ in 0 }
  public var double: @Sendable (_ forKey: String) -> Double = { _ in 0 }

  public var setAny: @Sendable (_ value: Any?, _ forKey: String) -> Void
  public var setFloat: @Sendable (_ value: Float, _ forKey: String) -> Void
  public var setDouble: @Sendable (_ value: Double, _ forKey: String) -> Void
  public var setInt: @Sendable (_ value: Int, _ forKey: String) -> Void
  public var setBool: @Sendable (_ value: Bool, _ forKey: String) -> Void
  public var setURL: @Sendable (_ value: URL?, _ forKey: String) -> Void

  public var removeObject: @Sendable (_ forKey: String) -> Void
  public var register: @Sendable (_ defaults: [String: Any]) -> Void

  @DependencyEndpoint(method: "observe")
  public var observeString: @Sendable (KeyPath<UserDefaults, String>) -> Stream<String> = { _ in .finished }
  @DependencyEndpoint(method: "observe")
  public var observeBool: @Sendable (KeyPath<UserDefaults, Bool>) -> Stream<Bool> = { _ in .finished }
  @DependencyEndpoint(method: "observe")
  public var observeInt: @Sendable (KeyPath<UserDefaults, Int>) -> Stream<Int> = { _ in .finished }
  @DependencyEndpoint(method: "observe")
  public var observeDouble: @Sendable (KeyPath<UserDefaults, Double>) -> Stream<Double> = { _ in .finished }

}

// MARK: DependencyKey

extension UserDefaultsClient: DependencyKey {

  public static let liveValue = Self(
    object: { suite.object(forKey: $0) },
    url: { suite.url(forKey: $0) },
    array: { suite.array(forKey: $0) },
    dictionary: { suite.dictionary(forKey: $0) },
    string: { suite.string(forKey: $0) },
    stringArray: { suite.stringArray(forKey: $0) },
    data: { suite.data(forKey: $0) },
    bool: { suite.bool(forKey: $0) },
    integer: { suite.integer(forKey: $0) },
    float: { suite.float(forKey: $0) },
    double: { suite.double(forKey: $0) },
    setAny: { suite.set($0, forKey: $1) },
    setFloat: { suite.set($0, forKey: $1) },
    setDouble: { suite.set($0, forKey: $1) },
    setInt: { suite.set($0, forKey: $1) },
    setBool: { suite.set($0, forKey: $1) },
    setURL: { suite.set($0, forKey: $1) },
    removeObject: { suite.removeObject(forKey: $0) },
    register: { suite.register(defaults: $0) },
    observeString: { keyValueStream(observed: suite, keyPath: $0) },
    observeBool: { keyValueStream(observed: suite, keyPath: $0) },
    observeInt: { keyValueStream(observed: suite, keyPath: $0) },
    observeDouble: { keyValueStream(observed: suite, keyPath: $0) }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var userDefaultsClient: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}
