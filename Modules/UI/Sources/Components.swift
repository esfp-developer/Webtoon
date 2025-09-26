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
