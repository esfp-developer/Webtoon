import SwiftUI
import ComposableArchitecture
import UI

// MARK: - Webtoon List View
public struct WebtoonListView: View {
    let store: StoreOf<WebtoonListFeature>
    
    public init(store: StoreOf<WebtoonListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            
            NavigationView {
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBarView(
                        text: $store.searchText.sending(\.searchTextChanged)
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
                            WebtoonGridView(
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

// MARK: - Preview
#if DEBUG
struct WebtoonListView_Previews: PreviewProvider {
    static var previews: some View {
        WithPerceptionTracking {
            WebtoonListView(
                store: Store(initialState: WebtoonListFeature.State()) {
                    WebtoonListFeature()
                }
            )
        }
    }
}
#endif
