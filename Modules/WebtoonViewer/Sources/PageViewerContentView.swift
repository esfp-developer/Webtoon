import SwiftUI
import Core
import UI

// MARK: - Page Viewer Content
struct PageViewerContentView: View {
    let presentationModel: PageViewerContentPresentationModel
    let onPageChange: (Int) -> Void
    let onTap: () -> Void
    
    init(episode: Episode, currentPageIndex: Int, onPageChange: @escaping (Int) -> Void, onTap: @escaping () -> Void) {
        self.presentationModel = PageViewerContentPresentationModel(episode: episode, currentPageIndex: currentPageIndex)
        self.onPageChange = onPageChange
        self.onTap = onTap
    }
    
    var body: some View {
        TabView(selection: Binding(
            get: { presentationModel.currentPageIndex },
            set: { onPageChange($0) }
        )) {
            ForEach(presentationModel.indexedPageImageURLs, id: \.0) { index, imageURL in
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
