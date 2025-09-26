import Foundation
import Core

// MARK: - Episodes Section Presentation Model
struct EpisodesSectionPresentationModel {
    let episodes: [Episode]
    
    var episodeCountText: String {
        "\(episodes.count)화"
    }
    
    var isEmpty: Bool {
        episodes.isEmpty
    }
    
    var hasEpisodes: Bool {
        !episodes.isEmpty
    }
    
    init(episodes: [Episode]) {
        self.episodes = episodes
    }
}
