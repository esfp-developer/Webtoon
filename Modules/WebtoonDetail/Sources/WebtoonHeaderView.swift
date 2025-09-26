import SwiftUI
import Core
import UI

// MARK: - Webtoon Header
struct WebtoonHeaderView: View {
    let presentationModel: WebtoonHeaderPresentationModel
    let onFavoriteToggle: () -> Void
    
    init(webtoon: Webtoon, isFavorite: Bool, onFavoriteToggle: @escaping () -> Void) {
        self.presentationModel = WebtoonHeaderPresentationModel(webtoon: webtoon, isFavorite: isFavorite)
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        VStack(spacing: Spacing.md.value) {
            HStack(alignment: .top, spacing: Spacing.md.value) {
                // Thumbnail
                CachedAsyncImage(url: presentationModel.thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                        .frame(width: 120, height: 160)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 160)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                .cornerRadius(.medium)
                
                // Info
                VStack(alignment: .leading, spacing: Spacing.sm.value) {
                    Text(presentationModel.webtoon.title)
                        .typography(.title2)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(presentationModel.webtoon.author)
                        .typography(.headline)
                        .foregroundColor(.textSecondary)
                    
                    HStack {
                        Text(presentationModel.webtoon.genre)
                            .typography(.callout)
                            .foregroundColor(.accent)
                            .padding(.horizontal, Spacing.sm.value)
                            .padding(.vertical, Spacing.xs.value)
                            .background(Color.accent.opacity(0.1))
                            .cornerRadius(.small)
                        
                        if let statusText = presentationModel.statusText {
                            Text(statusText)
                                .typography(.callout)
                                .foregroundColor(.green)
                                .padding(.horizontal, Spacing.sm.value)
                                .padding(.vertical, Spacing.xs.value)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(.small)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text(presentationModel.formattedRating)
                            .typography(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Button(action: onFavoriteToggle) {
                            Image(systemName: presentationModel.favoriteIconName)
                                .foregroundColor(presentationModel.favoriteIconColor)
                                .font(.title2)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Description
            Text(presentationModel.webtoon.description)
                .typography(.body)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .spacing(.md)
        .cardStyle()
    }
}
