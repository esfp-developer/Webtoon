import SwiftUI
import Core
import UI

// MARK: - Webtoon Grid
struct WebtoonGridView: View {
    let presentationModel: WebtoonGridPresentationModel
    let onWebtoonTap: (String) -> Void
    
    init(webtoons: [Webtoon], onWebtoonTap: @escaping (String) -> Void) {
        self.presentationModel = WebtoonGridPresentationModel(webtoons: webtoons)
        self.onWebtoonTap = onWebtoonTap
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: presentationModel.columns, spacing: Spacing.md.value) {
                ForEach(presentationModel.webtoons) { webtoon in
                    WebtoonCardView(webtoon: webtoon) {
                        onWebtoonTap(webtoon.id)
                    }
                }
            }
            .spacing(.md)
        }
    }
}
