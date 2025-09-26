import Foundation

// MARK: - 웹툰 모델
public struct Webtoon: Identifiable, Codable, Equatable {
    public let id: String
    public let title: String
    public let author: String
    public let description: String
    public let thumbnailURL: String
    public let genre: String
    public let isCompleted: Bool
    public let rating: Double
    public let episodes: [Episode]
    
    public init(
        id: String,
        title: String,
        author: String,
        description: String,
        thumbnailURL: String,
        genre: String,
        isCompleted: Bool,
        rating: Double,
        episodes: [Episode] = []
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.genre = genre
        self.isCompleted = isCompleted
        self.rating = rating
        self.episodes = episodes
    }
}

// MARK: - 에피소드 모델
public struct Episode: Identifiable, Codable, Equatable {
    public let id: String
    public let webtoonId: String
    public let title: String
    public let episodeNumber: Int
    public let thumbnailURL: String
    public let publishedDate: Date
    public let isRead: Bool
    public let isFree: Bool
    public let pageImageURLs: [String] // 웹툰 페이지 이미지들
    
    public init(
        id: String,
        webtoonId: String,
        title: String,
        episodeNumber: Int,
        thumbnailURL: String,
        publishedDate: Date,
        isRead: Bool = false,
        isFree: Bool = true,
        pageImageURLs: [String] = []
    ) {
        self.id = id
        self.webtoonId = webtoonId
        self.title = title
        self.episodeNumber = episodeNumber
        self.thumbnailURL = thumbnailURL
        self.publishedDate = publishedDate
        self.isRead = isRead
        self.isFree = isFree
        self.pageImageURLs = pageImageURLs
    }
}

// MARK: - 사용자 모델
public struct User: Identifiable, Codable, Equatable {
    public let id: String
    public let username: String
    public let email: String
    public let favoriteWebtoons: [String]
    public let readHistory: [String]
    
    public init(
        id: String,
        username: String,
        email: String,
        favoriteWebtoons: [String] = [],
        readHistory: [String] = []
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.favoriteWebtoons = favoriteWebtoons
        self.readHistory = readHistory
    }
}
