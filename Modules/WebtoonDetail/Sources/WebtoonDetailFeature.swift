import ComposableArchitecture
import Core

// MARK: - Webtoon Detail Feature
@Reducer
public struct WebtoonDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public let webtoonId: String
        public var webtoon: Webtoon?
        public var episodes: [Episode] = []
        public var isLoading = false
        public var errorMessage: String?
        public var isFavorite = false
        
        public init(webtoonId: String) {
            self.webtoonId = webtoonId
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadWebtoonDetail
        case loadEpisodes
        case webtoonDetailResponse(Result<Webtoon, NetworkError>)
        case episodesResponse(Result<[Episode], NetworkError>)
        case favoriteToggled
        case episodeTapped(String)
        case retryTapped
    }
    
    @Dependency(\.webtoonService) var webtoonService
    @Dependency(\.favoriteService) var favoriteService
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.webtoon == nil {
                    return .merge(
                        .send(.loadWebtoonDetail),
                        .send(.loadEpisodes)
                    )
                }
                return .none
                
            case .loadWebtoonDetail:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [webtoonId = state.webtoonId] send in
                    do {
                        let webtoon = try await webtoonService.fetchWebtoonDetail(webtoonId)
                        await send(.webtoonDetailResponse(.success(webtoon)))
                    } catch let error as NetworkError {
                        await send(.webtoonDetailResponse(.failure(error)))
                    } catch {
                        await send(.webtoonDetailResponse(.failure(.networkError(error.localizedDescription))))
                    }
                }
                
            case .loadEpisodes:
                return .run { [webtoonId = state.webtoonId] send in
                    do {
                        let episodes = try await webtoonService.fetchEpisodes(webtoonId)
                        await send(.episodesResponse(.success(episodes)))
                    } catch let error as NetworkError {
                        await send(.episodesResponse(.failure(error)))
                    } catch {
                        await send(.episodesResponse(.failure(.networkError(error.localizedDescription))))
                    }
                }
                
            case let .webtoonDetailResponse(.success(webtoon)):
                state.isLoading = false
                state.webtoon = webtoon
                state.isFavorite = favoriteService.isFavorite(webtoon.id)
                return .none
                
            case let .webtoonDetailResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = errorMessage(for: error)
                return .none
                
            case let .episodesResponse(.success(episodes)):
                state.episodes = episodes.sorted { $0.episodeNumber > $1.episodeNumber }
                return .none
                
            case let .episodesResponse(.failure(error)):
                if state.webtoon == nil {
                    state.errorMessage = errorMessage(for: error)
                }
                return .none
                
            case .favoriteToggled:
                guard let webtoon = state.webtoon else { return .none }
                
                state.isFavorite = favoriteService.toggleFavorite(webtoon.id)
                return .none
                
            case .retryTapped:
                return .merge(
                    .send(.loadWebtoonDetail),
                    .send(.loadEpisodes)
                )
                
            default:
                return .none
            }
        }
    }
    
    private func errorMessage(for error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .noData:
            return "데이터를 불러올 수 없습니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .statusCode(let code):
            return "서버 오류 (코드: \(code))"
        case .decodingError(let message):
            return "데이터 파싱 오류: \(message)"
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }
}

