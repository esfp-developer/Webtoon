import SwiftUI
import ComposableArchitecture
import Core
import UI

// MARK: - Webtoon Viewer Feature
@Reducer
public struct WebtoonViewerFeature {
    @ObservableState
    public struct State: Equatable {
        public let episodeId: String
        public var episode: Episode?
        public var currentPageIndex: Int = 0
        public var isLoading = false
        public var errorMessage: String?
        public var viewerMode: ViewerMode = .scroll
        public var isNavigationHidden = false
        
        public var hasNextPage: Bool {
            guard let episode = episode else { return false }
            return currentPageIndex < episode.pageImageURLs.count - 1
        }
        
        public var hasPreviousPage: Bool {
            return currentPageIndex > 0
        }
        
        public init(episodeId: String) {
            self.episodeId = episodeId
        }
    }
    
    public enum ViewerMode: String, CaseIterable, Equatable {
        case scroll = "스크롤"
        case page = "페이지"
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadEpisode
        case episodeResponse(Result<Episode, NetworkError>)
        case nextPage
        case previousPage
        case goToPage(Int)
        case toggleViewerMode
        case toggleNavigationBar
        case retryTapped
    }
    
    @Dependency(\.networkService) var networkService
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.episode == nil {
                    return .send(.loadEpisode)
                }
                return .none
                
            case .loadEpisode:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [episodeId = state.episodeId] send in
                    do {
                        let episode = try await networkService.fetchEpisodeDetail(episodeId)
                        await send(.episodeResponse(.success(episode)))
                    } catch let error as NetworkError {
                        await send(.episodeResponse(.failure(error)))
                    } catch {
                        await send(.episodeResponse(.failure(.networkError(error.localizedDescription))))
                    }
                }
                
            case let .episodeResponse(.success(episode)):
                state.isLoading = false
                state.episode = episode
                return .none
                
            case let .episodeResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = errorMessage(for: error)
                return .none
                
            case .nextPage:
                if state.hasNextPage {
                    state.currentPageIndex += 1
                }
                return .none
                
            case .previousPage:
                if state.hasPreviousPage {
                    state.currentPageIndex -= 1
                }
                return .none
                
            case let .goToPage(index):
                guard let episode = state.episode,
                      index >= 0 && index < episode.pageImageURLs.count else {
                    return .none
                }
                state.currentPageIndex = index
                return .none
                
            case .toggleViewerMode:
                state.viewerMode = state.viewerMode == .scroll ? .page : .scroll
                return .none
                
            case .toggleNavigationBar:
                state.isNavigationHidden.toggle()
                return .none
                
            case .retryTapped:
                return .send(.loadEpisode)
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

