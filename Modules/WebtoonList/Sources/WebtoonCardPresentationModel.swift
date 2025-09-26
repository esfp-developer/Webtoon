import Foundation
import Core

// MARK: - Webtoon Card Presentation Model
struct WebtoonCardPresentationModel {
    let webtoon: Webtoon
    
    var formattedRating: String {
        String(format: "%.1f", webtoon.rating)
    }
    
    var thumbnailURL: String {
        webtoon.thumbnailURL.isEmpty ? "" : webtoon.thumbnailURL
    }
    
    init(webtoon: Webtoon) {
        self.webtoon = webtoon
    }
}
