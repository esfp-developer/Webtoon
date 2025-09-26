import SwiftUI
import Core
import ComposableArchitecture

@main
struct WebtoonApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppFeature.State(),
                    reducer: {
                        AppFeature()
                    }, withDependencies: {
                        // TODO: - 🚧 테스트용 디펜던시 주입
                        $0.webtoonService = MockWebtoonService()
                        $0.favoriteService = MockFavoriteService()
                    }
                )
            )
        }
    }
}
