import SwiftUI
import ComposableArchitecture
import UI

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
                        WebtoonHeaderView(
                            webtoon: webtoon,
                            isFavorite: store.isFavorite,
                            onFavoriteToggle: {
                                store.send(.favoriteToggled)
                            }
                        )
                        
                        // Episodes
                        EpisodesSectionView(
                            presentationModel: EpisodesSectionPresentationModel(episodes: store.episodes),
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

// MARK: - Preview
#if DEBUG
struct WebtoonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WithPerceptionTracking {
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
}
#endif
