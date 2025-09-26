import SwiftUI
import Core

// MARK: - Async Image with Cache
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: String
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    public init(
        url: String,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    public var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                content(image)
            case .failure(_):
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("이미지 로딩 실패")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            case .empty:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
    }
}

// MARK: - Webtoon Card
public struct WebtoonCard: View {
    let webtoon: Webtoon
    let onTap: () -> Void
    
    public init(webtoon: Webtoon, onTap: @escaping () -> Void) {
        self.webtoon = webtoon
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm.value) {
                // Thumbnail
                CachedAsyncImage(url: webtoon.thumbnailURL) { image in
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
                    Text(webtoon.title)
                        .typography(.headline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    Text(webtoon.author)
                        .typography(.subheadline)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(webtoon.genre)
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
                            
                            Text(String(format: "%.1f", webtoon.rating))
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

// MARK: - Episode Row
public struct EpisodeRow: View {
    let episode: Episode
    let onTap: () -> Void
    
    public init(episode: Episode, onTap: @escaping () -> Void) {
        self.episode = episode
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md.value) {
                // Thumbnail
                CachedAsyncImage(url: episode.thumbnailURL) { image in
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
                        Text("#\(episode.episodeNumber)")
                            .typography(.caption1)
                            .foregroundColor(.accent)
                            .padding(.horizontal, Spacing.sm.value)
                            .padding(.vertical, Spacing.xs.value)
                            .background(Color.accent.opacity(0.1))
                            .cornerRadius(.small)
                        
                        if !episode.isFree {
                            Text("유료")
                                .typography(.caption1)
                                .foregroundColor(.orange)
                                .padding(.horizontal, Spacing.sm.value)
                                .padding(.vertical, Spacing.xs.value)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(.small)
                        }
                        
                        Spacer()
                        
                        if episode.isRead {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    Text(episode.title)
                        .typography(.body)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text(episode.publishedDate.timeAgo)
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

// MARK: - Loading View
public struct LoadingView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: Spacing.md.value) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("로딩 중...")
                .typography(.body)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}

// MARK: - Error View
public struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    public init(message: String, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }
    
    public var body: some View {
        VStack(spacing: Spacing.lg.value) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("오류가 발생했습니다")
                .typography(.title2)
                .foregroundColor(.textPrimary)
            
            Text(message)
                .typography(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("다시 시도", action: onRetry)
                .spacing(.md)
                .primaryButton()
        }
        .spacing(.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}

// MARK: - Empty State View
public struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    public init(
        title: String,
        message: String,
        systemImage: String = "tray"
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
    }
    
    public var body: some View {
        VStack(spacing: Spacing.lg.value) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(.textSecondary)
            
            Text(title)
                .typography(.title2)
                .foregroundColor(.textPrimary)
            
            Text(message)
                .typography(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .spacing(.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}
