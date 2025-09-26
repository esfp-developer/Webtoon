import SwiftUI
import Core
import UI

// MARK: - Scroll Viewer Content
struct ScrollViewerContentView: View {
    let presentationModel: ScrollViewerContentPresentationModel
    let onTap: () -> Void
    
    init(episode: Episode, onTap: @escaping () -> Void) {
        self.presentationModel = ScrollViewerContentPresentationModel(episode: episode)
        self.onTap = onTap
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(presentationModel.indexedPageImageURLs, id: \.0) { index, imageURL in
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
