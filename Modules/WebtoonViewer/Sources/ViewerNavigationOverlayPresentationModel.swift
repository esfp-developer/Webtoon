import Foundation
import Core

// MARK: - Viewer Navigation Overlay Presentation Model
struct ViewerNavigationOverlayPresentationModel {
    let episode: Episode
    let currentPageIndex: Int
    let viewerMode: WebtoonViewerFeature.ViewerMode
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    
    var episodeTitle: String {
        episode.title
    }
    
    var viewerModeText: String {
        viewerMode.rawValue
    }
    
    var pageIndicatorText: String {
        "\(currentPageIndex + 1) / \(episode.pageImageURLs.count)"
    }
    
    var isPageMode: Bool {
        viewerMode == .page
    }
    
    var previousButtonOpacity: Double {
        hasPreviousPage ? 1 : 0.5
    }
    
    var nextButtonOpacity: Double {
        hasNextPage ? 1 : 0.5
    }
    
    init(episode: Episode, currentPageIndex: Int, viewerMode: WebtoonViewerFeature.ViewerMode, hasNextPage: Bool, hasPreviousPage: Bool) {
        self.episode = episode
        self.currentPageIndex = currentPageIndex
        self.viewerMode = viewerMode
        self.hasNextPage = hasNextPage
        self.hasPreviousPage = hasPreviousPage
    }
}
