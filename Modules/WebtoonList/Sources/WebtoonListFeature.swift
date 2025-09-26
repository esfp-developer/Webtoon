import ComposableArchitecture
import Core

// MARK: - Webtoon List Feature
@Reducer
public struct WebtoonListFeature {
    @ObservableState
    public struct State: Equatable {
        public var webtoons: [Webtoon] = []
        public var isLoading = false
        public var errorMessage: String?
        public var searchText = ""
        
        public var filteredWebtoons: [Webtoon] {
            if searchText.isEmpty {
                return webtoons
            }
            return webtoons.filter { webtoon in
                webtoon.title.localizedCaseInsensitiveContains(searchText) ||
                webtoon.author.localizedCaseInsensitiveContains(searchText) ||
                webtoon.genre.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadWebtoons
        case webtoonsResponse(Result<[Webtoon], NetworkError>)
        case searchTextChanged(String)
        case webtoonTapped(String)
        case retryTapped
    }
    
    @Dependency(\.webtoonService) var webtoonService
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.webtoons.isEmpty {
                    return .send(.loadWebtoons)
                }
                return .none
                
            case .loadWebtoons:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        let webtoons = try await webtoonService.fetchWebtoons(genre: nil, page: 1, limit: 20)
                        await send(.webtoonsResponse(.success(webtoons)))
                    } catch let error as NetworkError {
                        await send(.webtoonsResponse(.failure(error)))
                    } catch {
                        await send(.webtoonsResponse(.failure(.networkError(error.localizedDescription))))
                    }
                }
                
            case let .webtoonsResponse(.success(webtoons)):
                state.isLoading = false
                state.webtoons = webtoons
                return .none
                
            case let .webtoonsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = errorMessage(for: error)
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
                
            case .retryTapped:
                return .send(.loadWebtoons)
                
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

