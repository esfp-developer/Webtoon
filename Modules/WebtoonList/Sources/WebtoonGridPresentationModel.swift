import SwiftUI
import Core

// MARK: - Webtoon Grid Presentation Model
struct WebtoonGridPresentationModel {
    let webtoons: [Webtoon]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var isEmpty: Bool {
        webtoons.isEmpty
    }
    
    var hasWebtoons: Bool {
        !webtoons.isEmpty
    }
    
    init(webtoons: [Webtoon]) {
        self.webtoons = webtoons
    }
}
