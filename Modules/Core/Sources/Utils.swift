import Foundation

// MARK: - Date Extensions
public extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
public extension String {
    var isValidURL: Bool {
        URL(string: self) != nil
    }
    
    func truncated(to length: Int, trailing: String = "...") -> String {
        return count > length ? prefix(length) + trailing : self
    }
}

// MARK: - Array Extensions
public extension Array where Element: Identifiable {
    func element(with id: Element.ID) -> Element? {
        first { $0.id == id }
    }
    
    mutating func update(_ element: Element) {
        if let index = firstIndex(where: { $0.id == element.id }) {
            self[index] = element
        }
    }
}

// MARK: - UserDefaults Extensions
public extension UserDefaults {
    private enum Keys {
        static let favoriteWebtoons = "favorite_webtoons"
        static let readHistory = "read_history"
        static let lastReadEpisode = "last_read_episode"
    }
    
    var favoriteWebtoons: [String] {
        get { stringArray(forKey: Keys.favoriteWebtoons) ?? [] }
        set { set(newValue, forKey: Keys.favoriteWebtoons) }
    }
    
    var readHistory: [String] {
        get { stringArray(forKey: Keys.readHistory) ?? [] }
        set { set(newValue, forKey: Keys.readHistory) }
    }
    
    func lastReadEpisode(for webtoonId: String) -> String? {
        string(forKey: "\(Keys.lastReadEpisode)_\(webtoonId)")
    }
    
    func setLastReadEpisode(_ episodeId: String, for webtoonId: String) {
        set(episodeId, forKey: "\(Keys.lastReadEpisode)_\(webtoonId)")
    }
}

// MARK: - Constants
public enum Constants {
    public enum Layout {
        public static let defaultPadding: CGFloat = 16
        public static let smallPadding: CGFloat = 8
        public static let largePadding: CGFloat = 24
        public static let cornerRadius: CGFloat = 12
        public static let cardCornerRadius: CGFloat = 8
    }
    
    public enum Animation {
        public static let defaultDuration: Double = 0.3
        public static let quickDuration: Double = 0.15
        public static let slowDuration: Double = 0.5
    }
}

// MARK: - Image Cache
public class ImageCache {
    public static let shared = ImageCache()
    private let cache = NSCache<NSString, NSData>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    public func data(for url: String) -> Data? {
        cache.object(forKey: url as NSString) as Data?
    }
    
    public func setData(_ data: Data, for url: String) {
        cache.setObject(data as NSData, forKey: url as NSString)
    }
    
    public func removeData(for url: String) {
        cache.removeObject(forKey: url as NSString)
    }
    
    public func clearAll() {
        cache.removeAllObjects()
    }
}
