import SwiftUI
import ComposableArchitecture
import Core
import UI
import WebtoonList
import WebtoonDetail
import WebtoonViewer

// MARK: - App Feature
@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var webtoonList = WebtoonListFeature.State()
        var path = StackState<Path.State>()
        
        init() {}
    }
    
    enum Action: Equatable {
        case webtoonList(WebtoonListFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case webtoonDetail(WebtoonDetailFeature.State)
            case webtoonViewer(WebtoonViewerFeature.State)
        }
        
        enum Action: Equatable {
            case webtoonDetail(WebtoonDetailFeature.Action)
            case webtoonViewer(WebtoonViewerFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.webtoonDetail, action: \.webtoonDetail) {
                WebtoonDetailFeature()
            }
            Scope(state: \.webtoonViewer, action: \.webtoonViewer) {
                WebtoonViewerFeature()
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.webtoonList, action: \.webtoonList) {
            WebtoonListFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .webtoonList(.webtoonTapped(webtoonId)):
                state.path.append(.webtoonDetail(WebtoonDetailFeature.State(webtoonId: webtoonId)))
                return .none
                
            case .webtoonList:
                return .none
                
            case let .path(.element(id: _, action: .webtoonDetail(.episodeTapped(episodeId)))):
                state.path.append(.webtoonViewer(WebtoonViewerFeature.State(episodeId: episodeId)))
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}

// MARK: - App View
struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: \.path)
        ) {
            WebtoonListView(
                store: store.scope(
                    state: \.webtoonList,
                    action: \.webtoonList
                )
            )
        } destination: { store in
            switch store.state {
            case .webtoonDetail:
                if let webtoonDetailStore = store.scope(
                    state: \.webtoonDetail,
                    action: \.webtoonDetail
                ) {
                    WebtoonDetailView(store: webtoonDetailStore)
                }
            case .webtoonViewer:
                if let webtoonViewerStore = store.scope(
                    state: \.webtoonViewer,
                    action: \.webtoonViewer
                ) {
                    WebtoonViewerView(store: webtoonViewerStore)
                }
            }
        }
    }
}
