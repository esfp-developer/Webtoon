import Foundation
import ComposableArchitecture

// MARK: - Favorite Service Protocol
public protocol FavoriteServiceProtocol {
    func getFavorites() -> [String]
    func addFavorite(_ webtoonId: String)
    func removeFavorite(_ webtoonId: String)
    func isFavorite(_ webtoonId: String) -> Bool
    func toggleFavorite(_ webtoonId: String) -> Bool // Returns new favorite status
}

// MARK: - Favorite Service
public struct FavoriteService: FavoriteServiceProtocol {
    private let storage: UserDefaultsStorageProtocol
    
    public init(storage: UserDefaultsStorageProtocol) {
        self.storage = storage
    }
    
    private static let favoritesKey = "favoriteWebtoons"
    
    public func getFavorites() -> [String] {
        return storage.get([String].self, forKey: Self.favoritesKey) ?? []
    }
    
    public func addFavorite(_ webtoonId: String) {
        var favorites = getFavorites()
        if !favorites.contains(webtoonId) {
            favorites.append(webtoonId)
            storage.set(favorites, forKey: Self.favoritesKey)
        }
    }
    
    public func removeFavorite(_ webtoonId: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0 == webtoonId }
        storage.set(favorites, forKey: Self.favoritesKey)
    }
    
    public func isFavorite(_ webtoonId: String) -> Bool {
        return getFavorites().contains(webtoonId)
    }
    
    public func toggleFavorite(_ webtoonId: String) -> Bool {
        let currentlyFavorite = isFavorite(webtoonId)
        
        if currentlyFavorite {
            removeFavorite(webtoonId)
        } else {
            addFavorite(webtoonId)
        }
        
        return !currentlyFavorite // Return new status
    }
}

// MARK: - Mock Favorite Service
public class MockFavoriteService: FavoriteServiceProtocol {
    private var favorites: Set<String>
    
    public init(initialFavorites: [String] = ["1", "2"]) {
        self.favorites = Set(initialFavorites)
    }
    
    public func getFavorites() -> [String] {
        return Array(favorites)
    }
    
    public func addFavorite(_ webtoonId: String) {
        favorites.insert(webtoonId)
    }
    
    public func removeFavorite(_ webtoonId: String) {
        favorites.remove(webtoonId)
    }
    
    public func isFavorite(_ webtoonId: String) -> Bool {
        return favorites.contains(webtoonId)
    }
    
    public func toggleFavorite(_ webtoonId: String) -> Bool {
        let currentlyFavorite = isFavorite(webtoonId)
        
        if currentlyFavorite {
            removeFavorite(webtoonId)
        } else {
            addFavorite(webtoonId)
        }
        
        return !currentlyFavorite
    }
}

// MARK: - Dependency Key
extension FavoriteService: DependencyKey {
    public static let liveValue: FavoriteServiceProtocol = FavoriteService(storage: UserDefaultsStorage())
    public static let testValue: FavoriteServiceProtocol = MockFavoriteService()
}

extension DependencyValues {
    public var favoriteService: FavoriteServiceProtocol {
        get { self[FavoriteService.self] }
        set { self[FavoriteService.self] = newValue }
    }
}
