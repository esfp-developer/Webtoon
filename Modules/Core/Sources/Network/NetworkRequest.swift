import Foundation

// MARK: - HTTP Method
public enum HTTPMethod: String, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Network Request Protocol
public protocol NetworkRequest {
    associatedtype ResponseType: Codable
    
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var parameters: [String: Any]? { get }
    var body: Data? { get }
    var timeout: TimeInterval { get }
}

// MARK: - Default Network Request Implementation
public extension NetworkRequest {
    var baseURL: String { "https://api.webtoon.com/v1" }
    var method: HTTPMethod { .GET }
    var headers: [String: String] { 
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
    var timeout: TimeInterval { 30.0 }
    
    var fullURL: String {
        var url = baseURL + path
        
        if let parameters = parameters, !parameters.isEmpty {
            let queryItems = parameters.map { key, value in
                "\(key)=\(value)"
            }.joined(separator: "&")
            url += "?" + queryItems
        }
        
        return url
    }
}

// MARK: - Webtoon API Requests
public struct WebtoonListRequest: NetworkRequest {
    public typealias ResponseType = [Webtoon]
    
    public let path = "/webtoons"
    public let genre: String?
    public let page: Int
    public let limit: Int
    
    public init(genre: String? = nil, page: Int = 1, limit: Int = 20) {
        self.genre = genre
        self.page = page
        self.limit = limit
    }
    
    public var parameters: [String: Any]? {
        var params: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        if let genre = genre {
            params["genre"] = genre
        }
        
        return params
    }
}

public struct WebtoonDetailRequest: NetworkRequest {
    public typealias ResponseType = Webtoon
    
    public let webtoonId: String
    public var path: String { "/webtoons/\(webtoonId)" }
    
    public init(webtoonId: String) {
        self.webtoonId = webtoonId
    }
}

public struct EpisodesRequest: NetworkRequest {
    public typealias ResponseType = [Episode]
    
    public let webtoonId: String
    public var path: String { "/webtoons/\(webtoonId)/episodes" }
    
    public init(webtoonId: String) {
        self.webtoonId = webtoonId
    }
}

public struct EpisodeDetailRequest: NetworkRequest {
    public typealias ResponseType = Episode
    
    public let episodeId: String
    public var path: String { "/episodes/\(episodeId)" }
    
    public init(episodeId: String) {
        self.episodeId = episodeId
    }
}
