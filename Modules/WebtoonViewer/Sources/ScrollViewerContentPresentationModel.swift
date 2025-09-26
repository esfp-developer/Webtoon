import Foundation
import Core

// MARK: - Scroll Viewer Content Presentation Model
struct ScrollViewerContentPresentationModel {
    let episode: Episode
    
    var pageImageURLs: [String] {
        episode.pageImageURLs
    }
    
    var indexedPageImageURLs: [(Int, String)] {
        Array(episode.pageImageURLs.enumerated())
    }
    
    init(episode: Episode) {
        self.episode = episode
    }
}
