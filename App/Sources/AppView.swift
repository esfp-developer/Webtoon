import SwiftUI
import ComposableArchitecture
import WebtoonList
import WebtoonDetail
import WebtoonViewer

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
