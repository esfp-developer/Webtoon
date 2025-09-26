import SwiftUI
import ComposableArchitecture
import Core
import UI

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
    
    @Dependency(\.networkService) var networkService
    
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
                        let webtoons = try await networkService.fetchWebtoons()
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
                
            case .webtoonTapped:
                // Navigation logic will be handled by parent
                return .none
                
            case .retryTapped:
                return .send(.loadWebtoons)
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

// MARK: - Webtoon List View
public struct WebtoonListView: View {
    let store: StoreOf<WebtoonListFeature>
    
    public init(store: StoreOf<WebtoonListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationView {
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(
                        text: Binding(
                            get: { store.searchText },
                            set: { store.send(.searchTextChanged($0)) }
                        )
                    )
                    .spacing(.md)
                    
                    // Content
                    Group {
                        if store.isLoading {
                            LoadingView()
                        } else if let errorMessage = store.errorMessage {
                            ErrorView(message: errorMessage) {
                                store.send(.retryTapped)
                            }
                        } else if store.filteredWebtoons.isEmpty {
                            EmptyStateView(
                                title: "웹툰이 없습니다",
                                message: store.searchText.isEmpty ?
                                    "아직 등록된 웹툰이 없습니다." :
                                    "'\(store.searchText)'에 대한 검색 결과가 없습니다.",
                                systemImage: "book.closed"
                            )
                        } else {
                            WebtoonGrid(
                                webtoons: store.filteredWebtoons,
                                onWebtoonTap: { webtoonId in
                                    store.send(.webtoonTapped(webtoonId))
                                }
                            )
                        }
                    }
                }
                .navigationTitle("웹툰")
                .background(Color.backgroundColor)
                .onAppear {
                    store.send(.onAppear)
                }
            }
        }
    }
}

// MARK: - Search Bar
private struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            
            TextField("웹툰 검색...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .spacing(.md)
        .background(Color.cardBackgroundColor)
        .cornerRadius(.medium)
    }
}

// MARK: - Webtoon Grid
private struct WebtoonGrid: View {
    let webtoons: [Webtoon]
    let onWebtoonTap: (String) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.md.value) {
                ForEach(webtoons) { webtoon in
                    WebtoonCard(webtoon: webtoon) {
                        onWebtoonTap(webtoon.id)
                    }
                }
            }
            .spacing(.md)
        }
    }
}

// MARK: - Preview
#if DEBUG
struct WebtoonListView_Previews: PreviewProvider {
    static var previews: some View {
        WebtoonListView(
            store: Store(initialState: WebtoonListFeature.State()) {
                WebtoonListFeature()
            }
        )
    }
}
#endif
