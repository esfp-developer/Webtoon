import SwiftUI
import Core
import UI

// MARK: - Episode Row
struct EpisodeRowView: View {
    let presentationModel: EpisodeRowPresentationModel
    let onTap: () -> Void
    
    init(episode: Episode, onTap: @escaping () -> Void) {
        self.presentationModel = EpisodeRowPresentationModel(episode: episode)
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md.value) {
                // Thumbnail
                CachedAsyncImage(url: presentationModel.thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 80, height: 45)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 45)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.5)
                        )
                }
                .cornerRadius(.small)
                
                // Info
                VStack(alignment: .leading, spacing: Spacing.xs.value) {
                    HStack {
                        Text(presentationModel.episodeNumberText)
                            .typography(.caption1)
                            .foregroundColor(.accent)
                            .padding(.horizontal, Spacing.sm.value)
                            .padding(.vertical, Spacing.xs.value)
                            .background(Color.accent.opacity(0.1))
                            .cornerRadius(.small)
                        
                        if presentationModel.showPaidStatus,
                           let paidStatusText = presentationModel.paidStatusText {
                            Text(paidStatusText)
                                .typography(.caption1)
                                .foregroundColor(.orange)
                                .padding(.horizontal, Spacing.sm.value)
                                .padding(.vertical, Spacing.xs.value)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(.small)
                        }
                        
                        Spacer()
                        
                        if presentationModel.showReadStatus {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    Text(presentationModel.episode.title)
                        .typography(.body)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text(presentationModel.formattedPublishedDate)
                        .typography(.caption1)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textSecondary)
                    .font(.caption)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .spacing(.md)
        .background(Color.cardBackgroundColor)
        .cornerRadius(.medium)
    }
}
