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
                
            case .episodeTapped:
                // Episode reading logic will be handled by parent or navigation
                return .none
                
            case .retryTapped:
                return .merge(
                    .send(.loadWebtoonDetail),
                    .send(.loadEpisodes)
                )
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

// MARK: - Webtoon Detail View
public struct WebtoonDetailView: View {
    let store: StoreOf<WebtoonDetailFeature>
    
    public init(store: StoreOf<WebtoonDetailFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                if store.isLoading && store.webtoon == nil {
                    LoadingView()
                        .frame(height: 400)
                } else if let errorMessage = store.errorMessage, store.webtoon == nil {
                    ErrorView(message: errorMessage) {
                        store.send(.retryTapped)
                    }
                    .frame(height: 400)
                } else if let webtoon = store.webtoon {
                    VStack(spacing: Spacing.lg.value) {
                        // Header
                        WebtoonHeader(
                            webtoon: webtoon,
                            isFavorite: store.isFavorite,
                            onFavoriteToggle: {
                                store.send(.favoriteToggled)
                            }
                        )
                        
                        // Episodes
                        EpisodesSection(
                            episodes: store.episodes,
                            onEpisodeTap: { episodeId in
                                store.send(.episodeTapped(episodeId))
                            }
                        )
                    }
                    .spacing(.md)
                }
            }
            .background(Color.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Webtoon Header
private struct WebtoonHeader: View {
    let webtoon: Webtoon
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.md.value) {
            HStack(alignment: .top, spacing: Spacing.md.value) {
                // Thumbnail
                CachedAsyncImage(url: webtoon.thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                        .frame(width: 120, height: 160)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 160)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                .cornerRadius(.medium)
                
                // Info
                VStack(alignment: .leading, spacing: Spacing.sm.value) {
                    Text(webtoon.title)
                        .typography(.title2)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(webtoon.author)
                        .typography(.headline)
                        .foregroundColor(.textSecondary)
                    
                    HStack {
                        Text(webtoon.genre)
                            .typography(.callout)
                            .foregroundColor(.accent)
                            .padding(.horizontal, Spacing.sm.value)
                            .padding(.vertical, Spacing.xs.value)
                            .background(Color.accent.opacity(0.1))
                            .cornerRadius(.small)
                        
                        if webtoon.isCompleted {
                            Text("완결")
                                .typography(.callout)
                                .foregroundColor(.green)
                                .padding(.horizontal, Spacing.sm.value)
                                .padding(.vertical, Spacing.xs.value)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(.small)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", webtoon.rating))
                            .typography(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Button(action: onFavoriteToggle) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .textSecondary)
                                .font(.title2)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Description
            Text(webtoon.description)
                .typography(.body)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .spacing(.md)
        .cardStyle()
    }
}

// MARK: - Episodes Section
private struct EpisodesSection: View {
    let episodes: [Episode]
    let onEpisodeTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md.value) {
            HStack {
                Text("에피소드")
                    .typography(.title3)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(episodes.count)화")
                    .typography(.callout)
                    .foregroundColor(.textSecondary)
            }
            .spacing(.md)
            
            if episodes.isEmpty {
                EmptyStateView(
                    title: "에피소드가 없습니다",
                    message: "아직 등록된 에피소드가 없습니다.",
                    systemImage: "doc.text"
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: Spacing.sm.value) {
                    ForEach(episodes) { episode in
                        EpisodeRow(episode: episode) {
                            onEpisodeTap(episode.id)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct WebtoonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WebtoonDetailView(
                store: Store(
                    initialState: WebtoonDetailFeature.State(webtoonId: "1")
                ) {
                    WebtoonDetailFeature()
                }
            )
        }
    }
}
#endif
