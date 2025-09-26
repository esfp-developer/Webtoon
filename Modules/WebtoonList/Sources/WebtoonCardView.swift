import SwiftUI
import Core
import UI

// MARK: - Webtoon Card
struct WebtoonCardView: View {
    let presentationModel: WebtoonCardPresentationModel
    let onTap: () -> Void
    
    init(webtoon: Webtoon, onTap: @escaping () -> Void) {
        self.presentationModel = WebtoonCardPresentationModel(webtoon: webtoon)
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm.value) {
                // Thumbnail
                CachedAsyncImage(url: presentationModel.thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(3/4, contentMode: .fill)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                .cornerRadius(.medium)
                
                // Info
                VStack(alignment: .leading, spacing: Spacing.xs.value) {
                    Text(presentationModel.webtoon.title)
                        .typography(.headline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    Text(presentationModel.webtoon.author)
                        .typography(.subheadline)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(presentationModel.webtoon.genre)
                            .typography(.caption1)
                            .foregroundColor(.accent)
                            .padding(.horizontal, Spacing.sm.value)
                            .padding(.vertical, Spacing.xs.value)
                            .background(Color.accent.opacity(0.1))
                            .cornerRadius(.small)
                        
                        Spacer()
                        
                        HStack(spacing: Spacing.xs.value) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            
                            Text(presentationModel.formattedRating)
                                .typography(.caption1)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .spacing(.sm)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .cardStyle()
    }
}
