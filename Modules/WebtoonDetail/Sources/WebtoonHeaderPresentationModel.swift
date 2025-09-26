import SwiftUI
import Core

// MARK: - Webtoon Header Presentation Model
struct WebtoonHeaderPresentationModel {
    let webtoon: Webtoon
    let isFavorite: Bool
    
    // 계산된 프로퍼티들 - 뷰 로직을 캡슐화
    var formattedRating: String {
        String(format: "%.1f", webtoon.rating)
    }
    
    var statusText: String? {
        webtoon.isCompleted ? "완결" : nil
    }
    
    var favoriteIconName: String {
        isFavorite ? "heart.fill" : "heart"
    }
    
    var favoriteIconColor: Color {
        isFavorite ? .red : .textSecondary
    }
    
    // 썸네일 URL 유효성 검사
    var thumbnailURL: String {
        webtoon.thumbnailURL.isEmpty ? "" : webtoon.thumbnailURL
    }
    
    init(webtoon: Webtoon, isFavorite: Bool) {
        self.webtoon = webtoon
        self.isFavorite = isFavorite
    }
}
