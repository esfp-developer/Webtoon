import SwiftUI
import ComposableArchitecture
import Core
import UI

// MARK: - Webtoon Viewer View
public struct WebtoonViewerView: View {
    let store: StoreOf<WebtoonViewerFeature>
    
    public init(store: StoreOf<WebtoonViewerFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if store.isLoading {
                    LoadingView()
                } else if let errorMessage = store.errorMessage {
                    ErrorView(message: errorMessage) {
                        store.send(.retryTapped)
                    }
                } else if let episode = store.episode {
                    Group {
                        if store.viewerMode == .scroll {
                            ScrollViewerContentView(
                                episode: episode,
                                onTap: {
                                    store.send(.toggleNavigationBar)
                                }
                            )
                        } else {
                            PageViewerContentView(
                                episode: episode,
                                currentPageIndex: store.currentPageIndex,
                                onPageChange: { index in
                                    store.send(.goToPage(index))
                                },
                                onTap: {
                                    store.send(.toggleNavigationBar)
                                }
                            )
                        }
                    }
                }
                
                // Navigation Overlay
                if !store.isNavigationHidden, let episode = store.episode {
                    ViewerNavigationOverlayView(
                        episode: episode,
                        currentPageIndex: store.currentPageIndex,
                        viewerMode: store.viewerMode,
                        hasNextPage: store.hasNextPage,
                        hasPreviousPage: store.hasPreviousPage,
                        onPreviousPage: {
                            store.send(.previousPage)
                        },
                        onNextPage: {
                            store.send(.nextPage)
                        },
                        onToggleMode: {
                            store.send(.toggleViewerMode)
                        }
                    )
                }
            }
            .navigationBarHidden(store.isNavigationHidden)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct WebtoonViewerView_Previews: PreviewProvider {
    static var previews: some View {
        WebtoonViewerView(
            store: Store(
                initialState: WebtoonViewerFeature.State(episodeId: "ep1")
            ) {
                WebtoonViewerFeature()
            }
        )
    }
}
#endif
