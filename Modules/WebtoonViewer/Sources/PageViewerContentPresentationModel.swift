import Foundation
import Core

// MARK: - Page Viewer Content Presentation Model
struct PageViewerContentPresentationModel {
    let episode: Episode
    let currentPageIndex: Int
    
    var indexedPageImageURLs: [(Int, String)] {
        Array(episode.pageImageURLs.enumerated())
    }
    
    init(episode: Episode, currentPageIndex: Int) {
        self.episode = episode
        self.currentPageIndex = currentPageIndex
    }
}
