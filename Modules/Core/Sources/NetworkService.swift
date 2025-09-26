import Foundation
import ComposableArchitecture

// MARK: - Network Error
public enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
}

// MARK: - Network Service
public struct NetworkService {
    public var fetchWebtoons: () async throws -> [Webtoon]
    public var fetchWebtoonDetail: (String) async throws -> Webtoon
    public var fetchEpisodes: (String) async throws -> [Episode]
    public var fetchEpisodeDetail: (String) async throws -> Episode
    
    public init(
        fetchWebtoons: @escaping () async throws -> [Webtoon],
        fetchWebtoonDetail: @escaping (String) async throws -> Webtoon,
        fetchEpisodes: @escaping (String) async throws -> [Episode],
        fetchEpisodeDetail: @escaping (String) async throws -> Episode
    ) {
        self.fetchWebtoons = fetchWebtoons
        self.fetchWebtoonDetail = fetchWebtoonDetail
        self.fetchEpisodes = fetchEpisodes
        self.fetchEpisodeDetail = fetchEpisodeDetail
    }
}

// MARK: - Dependency Key
extension NetworkService: DependencyKey {
    public static let liveValue = NetworkService.live
    public static let testValue = NetworkService.mock
}

extension DependencyValues {
    public var networkService: NetworkService {
        get { self[NetworkService.self] }
        set { self[NetworkService.self] = newValue }
    }
}

// MARK: - Live Implementation
extension NetworkService {
    public static let live = NetworkService(
        fetchWebtoons: {
            // 실제 API 호출 로직
            // 여기서는 더미 데이터 반환
            return [
                Webtoon(
                    id: "1",
                    title: "나 혼자만 레벨업",
                    author: "추공",
                    description: "최약체 헌터가 최강이 되는 이야기",
                    thumbnailURL: "https://picsum.photos/300/400?random=101",
                    genre: "액션",
                    isCompleted: false,
                    rating: 9.8
                ),
                Webtoon(
                    id: "2",
                    title: "신의 탑",
                    author: "SIU",
                    description: "탑을 오르는 소년의 모험",
                    thumbnailURL: "https://picsum.photos/300/400?random=102",
                    genre: "판타지",
                    isCompleted: false,
                    rating: 9.5
                )
            ]
        },
        fetchWebtoonDetail: { id in
            // 실제 API 호출 로직
            switch id {
            case "1":
                return Webtoon(
                    id: id,
                    title: "나 혼자만 레벨업",
                    author: "추공",
                    description: "최약체 헌터가 최강이 되는 이야기",
                    thumbnailURL: "https://picsum.photos/300/400?random=101",
                    genre: "액션",
                    isCompleted: false,
                    rating: 9.8
                )
            case "2":
                return Webtoon(
                    id: id,
                    title: "신의 탑",
                    author: "SIU",
                    description: "탑을 오르는 소년의 모험",
                    thumbnailURL: "https://picsum.photos/300/400?random=102",
                    genre: "판타지",
                    isCompleted: false,
                    rating: 9.5
                )
            default:
                return Webtoon(
                    id: id,
                    title: "알 수 없는 웹툰",
                    author: "작가 미상",
                    description: "설명이 없습니다.",
                    thumbnailURL: "https://example.com/default.jpg",
                    genre: "기타",
                    isCompleted: true,
                    rating: 7.0
                )
            }
        },
        fetchEpisodes: { webtoonId in
            // 실제 API 호출 로직
            switch webtoonId {
            case "1": // 나 혼자만 레벨업
                return [
                    Episode(
                        id: "ep1_1",
                        webtoonId: webtoonId,
                        title: "1화 - 최약체 헌터",
                        episodeNumber: 1,
                        thumbnailURL: "https://picsum.photos/200/300?random=1",
                        publishedDate: Date(),
                        pageImageURLs: [
                            "https://picsum.photos/400/800?random=1",
                            "https://picsum.photos/400/800?random=2",
                            "https://picsum.photos/400/800?random=3"
                        ]
                    ),
                    Episode(
                        id: "ep1_2",
                        webtoonId: webtoonId,
                        title: "2화 - 각성",
                        episodeNumber: 2,
                        thumbnailURL: "https://picsum.photos/200/300?random=2",
                        publishedDate: Date(),
                        pageImageURLs: [
                            "https://picsum.photos/400/800?random=4",
                            "https://picsum.photos/400/800?random=5",
                            "https://picsum.photos/400/800?random=6"
                        ]
                    )
                ]
            case "2": // 신의 탑
                return [
                    Episode(
                        id: "ep2_1",
                        webtoonId: webtoonId,
                        title: "1화 - 탑",
                        episodeNumber: 1,
                        thumbnailURL: "https://picsum.photos/200/300?random=10",
                        publishedDate: Date(),
                        pageImageURLs: [
                            "https://picsum.photos/400/800?random=10",
                            "https://picsum.photos/400/800?random=11",
                            "https://picsum.photos/400/800?random=12"
                        ]
                    ),
                    Episode(
                        id: "ep2_2",
                        webtoonId: webtoonId,
                        title: "2화 - 밤",
                        episodeNumber: 2,
                        thumbnailURL: "https://picsum.photos/200/300?random=11",
                        publishedDate: Date(),
                        pageImageURLs: [
                            "https://picsum.photos/400/800?random=13",
                            "https://picsum.photos/400/800?random=14",
                            "https://picsum.photos/400/800?random=15"
                        ]
                    ),
                    Episode(
                        id: "ep2_3",
                        webtoonId: webtoonId,
                        title: "3화 - 라헬",
                        episodeNumber: 3,
                        thumbnailURL: "https://picsum.photos/200/300?random=12",
                        publishedDate: Date(),
                        pageImageURLs: [
                            "https://picsum.photos/400/800?random=16",
                            "https://picsum.photos/400/800?random=17",
                            "https://picsum.photos/400/800?random=18"
                        ]
                    )
                ]
            default:
                return []
            }
        },
        fetchEpisodeDetail: { episodeId in
            // 실제 API 호출 로직
            switch episodeId {
            case "ep1_1":
                return Episode(
                    id: episodeId,
                    webtoonId: "1",
                    title: "1화 - 최약체 헌터",
                    episodeNumber: 1,
                    thumbnailURL: "https://picsum.photos/200/300?random=1",
                    publishedDate: Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=1",
                        "https://picsum.photos/400/800?random=2",
                        "https://picsum.photos/400/800?random=3",
                        "https://picsum.photos/400/800?random=4",
                        "https://picsum.photos/400/800?random=5"
                    ]
                )
            case "ep1_2":
                return Episode(
                    id: episodeId,
                    webtoonId: "1",
                    title: "2화 - 각성",
                    episodeNumber: 2,
                    thumbnailURL: "https://picsum.photos/200/300?random=2",
                    publishedDate: Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=4",
                        "https://picsum.photos/400/800?random=5",
                        "https://picsum.photos/400/800?random=6",
                        "https://picsum.photos/400/800?random=7"
                    ]
                )
            case "ep2_1":
                return Episode(
                    id: episodeId,
                    webtoonId: "2",
                    title: "1화 - 탑",
                    episodeNumber: 1,
                    thumbnailURL: "https://picsum.photos/200/300?random=10",
                    publishedDate: Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=10",
                        "https://picsum.photos/400/800?random=11",
                        "https://picsum.photos/400/800?random=12",
                        "https://picsum.photos/400/800?random=13"
                    ]
                )
            case "ep2_2":
                return Episode(
                    id: episodeId,
                    webtoonId: "2",
                    title: "2화 - 밤",
                    episodeNumber: 2,
                    thumbnailURL: "https://picsum.photos/200/300?random=11",
                    publishedDate: Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=13",
                        "https://picsum.photos/400/800?random=14",
                        "https://picsum.photos/400/800?random=15",
                        "https://picsum.photos/400/800?random=16"
                    ]
                )
            case "ep2_3":
                return Episode(
                    id: episodeId,
                    webtoonId: "2",
                    title: "3화 - 라헬",
                    episodeNumber: 3,
                    thumbnailURL: "https://picsum.photos/200/300?random=12",
                    publishedDate: Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=16",
                        "https://picsum.photos/400/800?random=17",
                        "https://picsum.photos/400/800?random=18",
                        "https://picsum.photos/400/800?random=19"
                    ]
                )
            default:
                return Episode(
                    id: episodeId,
                    webtoonId: "unknown",
                    title: "알 수 없는 에피소드",
                    episodeNumber: 0,
                    thumbnailURL: "https://picsum.photos/200/300?random=99",
                    publishedDate: Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=99"
                    ]
                )
            }
        }
    )
}

// MARK: - Mock Implementation
extension NetworkService {
    public static let mock = NetworkService(
        fetchWebtoons: {
            return []
        },
        fetchWebtoonDetail: { _ in
            throw NetworkError.noData
        },
        fetchEpisodes: { _ in
            return []
        },
        fetchEpisodeDetail: { _ in
            throw NetworkError.noData
        }
    )
}
