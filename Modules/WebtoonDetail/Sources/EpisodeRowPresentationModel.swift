import SwiftUI
import Core

// MARK: - Episode Row Presentation Model
struct EpisodeRowPresentationModel {
    let episode: Episode
    
    var episodeNumberText: String {
        "#\(episode.episodeNumber)"
    }
    
    var paidStatusText: String? {
        episode.isFree ? nil : "유료"
    }
    
    var thumbnailURL: String {
        episode.thumbnailURL.isEmpty ? "" : episode.thumbnailURL
    }
    
    var formattedPublishedDate: String {
        episode.publishedDate.timeAgo
    }
    
    var showReadStatus: Bool {
        episode.isRead
    }
    
    var showPaidStatus: Bool {
        !episode.isFree
    }
    
    init(episode: Episode) {
        self.episode = episode
    }
}
