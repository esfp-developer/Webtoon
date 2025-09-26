import ComposableArchitecture
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
                
            case let .path(.element(id: _, action: .webtoonDetail(.episodeTapped(episodeId)))):
                state.path.append(.webtoonViewer(WebtoonViewerFeature.State(episodeId: episodeId)))
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}

