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
                            ScrollViewerContent(
                                episode: episode,
                                onTap: {
                                    store.send(.toggleNavigationBar)
                                }
                            )
                        } else {
                            PageViewerContent(
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
                    ViewerNavigationOverlay(
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

// MARK: - Scroll Viewer Content
private struct ScrollViewerContent: View {
    let episode: Episode
    let onTap: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(episode.pageImageURLs.enumerated()), id: \.offset) { index, imageURL in
                    CachedAsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(0.5, contentMode: .fit)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                    }
                    .onTapGesture {
                        onTap()
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Page Viewer Content
private struct PageViewerContent: View {
    let episode: Episode
    let currentPageIndex: Int
    let onPageChange: (Int) -> Void
    let onTap: () -> Void
    
    var body: some View {
        TabView(selection: Binding(
            get: { currentPageIndex },
            set: { onPageChange($0) }
        )) {
            ForEach(Array(episode.pageImageURLs.enumerated()), id: \.offset) { index, imageURL in
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(0.5, contentMode: .fit)
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.5)
                        )
                }
                .onTapGesture {
                    onTap()
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

// MARK: - Viewer Navigation Overlay
private struct ViewerNavigationOverlay: View {
    let episode: Episode
    let currentPageIndex: Int
    let viewerMode: WebtoonViewerFeature.ViewerMode
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    let onPreviousPage: () -> Void
    let onNextPage: () -> Void
    let onToggleMode: () -> Void
    
    var body: some View {
        VStack {
            // Top Navigation
            HStack {
                Text(episode.title)
                    .typography(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(viewerMode.rawValue) {
                    onToggleMode()
                }
                .spacing(.sm)
                .secondaryButton()
            }
            .spacing(.md)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.7), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
            )
            
            Spacer()
            
            // Bottom Navigation (Page Mode Only)
            if viewerMode == .page {
                HStack {
                    Button("이전") {
                        onPreviousPage()
                    }
                    .disabled(!hasPreviousPage)
                    .spacing(.md)
                    .secondaryButton()
                    .opacity(hasPreviousPage ? 1 : 0.5)
                    
                    Spacer()
                    
                    Text("\(currentPageIndex + 1) / \(episode.pageImageURLs.count)")
                        .typography(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.md.value)
                        .padding(.vertical, Spacing.sm.value)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(.medium)
                    
                    Spacer()
                    
                    Button("다음") {
                        onNextPage()
                    }
                    .disabled(!hasNextPage)
                    .spacing(.md)
                    .secondaryButton()
                    .opacity(hasNextPage ? 1 : 0.5)
                }
                .spacing(.md)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
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
