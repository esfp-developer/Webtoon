import Foundation
import ComposableArchitecture

// MARK: - Webtoon Service Protocol
public protocol WebtoonServiceProtocol {
    func fetchWebtoons(genre: String?, page: Int, limit: Int) async throws -> [Webtoon]
    func fetchWebtoonDetail(_ id: String) async throws -> Webtoon
    func fetchEpisodes(_ webtoonId: String) async throws -> [Episode]
    func fetchEpisodeDetail(_ episodeId: String) async throws -> Episode
}

// MARK: - Webtoon Service
public struct WebtoonService: WebtoonServiceProtocol {
    private let networkClient: NetworkClientProtocol
    
    public init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    public func fetchWebtoons(
        genre: String? = nil,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [Webtoon] {
        let request = WebtoonListRequest(genre: genre, page: page, limit: limit)
        return try await networkClient.execute(request)
    }
    
    public func fetchWebtoonDetail(_ id: String) async throws -> Webtoon {
        let request = WebtoonDetailRequest(webtoonId: id)
        return try await networkClient.execute(request)
    }
    
    public func fetchEpisodes(_ webtoonId: String) async throws -> [Episode] {
        let request = EpisodesRequest(webtoonId: webtoonId)
        return try await networkClient.execute(request)
    }
    
    public func fetchEpisodeDetail(_ episodeId: String) async throws -> Episode {
        let request = EpisodeDetailRequest(episodeId: episodeId)
        return try await networkClient.execute(request)
    }
}

// MARK: - Mock Webtoon Service
public struct MockWebtoonService: WebtoonServiceProtocol {
    public init() {}
    
    public func fetchWebtoons(
        genre: String? = nil,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [Webtoon] {
        // 실제 서버에서 받아올 데이터 시뮬레이션
        var webtoons = [
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
            ),
            Webtoon(
                id: "3",
                title: "외모지상주의",
                author: "박태준",
                description: "외모로 달라지는 인생",
                thumbnailURL: "https://picsum.photos/300/400?random=103",
                genre: "드라마",
                isCompleted: false,
                rating: 9.2
            ),
            Webtoon(
                id: "4",
                title: "전지적 독자 시점",
                author: "싱숑",
                description: "소설 속 세계가 현실이 된다면?",
                thumbnailURL: "https://picsum.photos/300/400?random=104",
                genre: "판타지",
                isCompleted: false,
                rating: 9.7
            )
        ]
        
        // 장르 필터링
        if let genre = genre {
            webtoons = webtoons.filter { $0.genre == genre }
        }
        
        // 페이징 처리
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, webtoons.count)
        
        guard startIndex < webtoons.count else {
            return []
        }
        
        return Array(webtoons[startIndex..<endIndex])
    }
    
    public func fetchWebtoonDetail(_ id: String) async throws -> Webtoon {
        let webtoons = try await fetchWebtoons()
        guard let webtoon = webtoons.first(where: { $0.id == id }) else {
            throw NetworkError.noData
        }
        return webtoon
    }
    
    public func fetchEpisodes(_ webtoonId: String) async throws -> [Episode] {
        switch webtoonId {
        case "1": // 나 혼자만 레벨업
            return [
                Episode(
                    id: "ep1_1",
                    webtoonId: webtoonId,
                    title: "1화 - 최약체 헌터",
                    episodeNumber: 1,
                    thumbnailURL: "https://picsum.photos/200/300?random=1",
                    publishedDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
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
                    publishedDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=4",
                        "https://picsum.photos/400/800?random=5",
                        "https://picsum.photos/400/800?random=6"
                    ]
                ),
                Episode(
                    id: "ep1_3",
                    webtoonId: webtoonId,
                    title: "3화 - 던전",
                    episodeNumber: 3,
                    thumbnailURL: "https://picsum.photos/200/300?random=3",
                    publishedDate: Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=7",
                        "https://picsum.photos/400/800?random=8",
                        "https://picsum.photos/400/800?random=9"
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
                    publishedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
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
                )
            ]
        case "3": // 외모지상주의
            return [
                Episode(
                    id: "ep3_1",
                    webtoonId: webtoonId,
                    title: "1화 - 시작",
                    episodeNumber: 1,
                    thumbnailURL: "https://picsum.photos/200/300?random=20",
                    publishedDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=20",
                        "https://picsum.photos/400/800?random=21",
                        "https://picsum.photos/400/800?random=22"
                    ]
                )
            ]
        case "4": // 전지적 독자 시점
            return [
                Episode(
                    id: "ep4_1",
                    webtoonId: webtoonId,
                    title: "1화 - 독자",
                    episodeNumber: 1,
                    thumbnailURL: "https://picsum.photos/200/300?random=30",
                    publishedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                    pageImageURLs: [
                        "https://picsum.photos/400/800?random=30",
                        "https://picsum.photos/400/800?random=31",
                        "https://picsum.photos/400/800?random=32"
                    ]
                )
            ]
        default:
            return []
        }
    }
    
    public func fetchEpisodeDetail(_ episodeId: String) async throws -> Episode {
        async let episodes1 = fetchEpisodes("1")
        async let episodes2 = fetchEpisodes("2")
        async let episodes3 = fetchEpisodes("3")
        async let episodes4 = fetchEpisodes("4")
        
        let allEpisodes = try await episodes1 + episodes2 + episodes3 + episodes4
        
        guard let episode = allEpisodes.first(where: { $0.id == episodeId }) else {
            throw NetworkError.noData
        }
        
        return episode
    }
}

// MARK: - Dependency Key
extension WebtoonService: DependencyKey {
    public static let liveValue: WebtoonServiceProtocol = WebtoonService(networkClient: NetworkClient())
    public static let testValue: WebtoonServiceProtocol = MockWebtoonService()
}

extension DependencyValues {
    public var webtoonService: WebtoonServiceProtocol {
        get { self[WebtoonService.self] }
        set { self[WebtoonService.self] = newValue }
    }
}
