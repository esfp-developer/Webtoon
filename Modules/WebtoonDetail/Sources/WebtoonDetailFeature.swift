import SwiftUI
import ComposableArchitecture
import Core
import UI

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
    
    @Dependency(\.networkService) var networkService
    
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
                        let webtoon = try await networkService.fetchWebtoonDetail(webtoonId)
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
                        let episodes = try await networkService.fetchEpisodes(webtoonId)
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
                state.isFavorite = UserDefaults.standard.favoriteWebtoons.contains(webtoon.id)
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
                
                state.isFavorite.toggle()
                var favorites = UserDefaults.standard.favoriteWebtoons
                
                if state.isFavorite {
                    if !favorites.contains(webtoon.id) {
                        favorites.append(webtoon.id)
                    }
                } else {
                    favorites.removeAll { $0 == webtoon.id }
                }
                
                UserDefaults.standard.favoriteWebtoons = favorites
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
        case .decodingError:
            return "데이터 형식이 올바르지 않습니다."
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        }
    }
}

