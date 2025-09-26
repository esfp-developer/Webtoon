import Foundation
import ComposableArchitecture

// MARK: - UserDefaults Storage Protocol
public protocol UserDefaultsStorageProtocol {
    func set<T>(_ value: T, forKey key: String) where T: Codable
    func get<T>(_ type: T.Type, forKey key: String) -> T? where T: Codable
    func remove(forKey key: String)
    func contains(key: String) -> Bool
}

// MARK: - UserDefaults Storage
public struct UserDefaultsStorage: UserDefaultsStorageProtocol {
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func set<T>(_ value: T, forKey key: String) where T: Codable {
        if let data = try? JSONEncoder().encode(value) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    public func get<T>(_ type: T.Type, forKey key: String) -> T? where T: Codable {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    public func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    public func contains(key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
}

// MARK: - Dependency Key
private enum UserDefaultsStorageKey: DependencyKey {
    static let liveValue: UserDefaultsStorageProtocol = UserDefaultsStorage()
}

public extension DependencyValues {
    var userDefaultsStorage: UserDefaultsStorageProtocol {
        get { self[UserDefaultsStorageKey.self] }
        set { self[UserDefaultsStorageKey.self] = newValue }
    }
}
