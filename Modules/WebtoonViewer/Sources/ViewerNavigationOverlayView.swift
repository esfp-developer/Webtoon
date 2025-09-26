import SwiftUI
import Core
import UI

// MARK: - Viewer Navigation Overlay
struct ViewerNavigationOverlayView: View {
    let presentationModel: ViewerNavigationOverlayPresentationModel
    let onPreviousPage: () -> Void
    let onNextPage: () -> Void
    let onToggleMode: () -> Void
    
    init(episode: Episode, currentPageIndex: Int, viewerMode: WebtoonViewerFeature.ViewerMode, hasNextPage: Bool, hasPreviousPage: Bool, onPreviousPage: @escaping () -> Void, onNextPage: @escaping () -> Void, onToggleMode: @escaping () -> Void) {
        self.presentationModel = ViewerNavigationOverlayPresentationModel(
            episode: episode,
            currentPageIndex: currentPageIndex,
            viewerMode: viewerMode,
            hasNextPage: hasNextPage,
            hasPreviousPage: hasPreviousPage
        )
        self.onPreviousPage = onPreviousPage
        self.onNextPage = onNextPage
        self.onToggleMode = onToggleMode
    }
    
    var body: some View {
        VStack {
            // Top Navigation
            HStack {
                Text(presentationModel.episodeTitle)
                    .typography(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(presentationModel.viewerModeText) {
                    onToggleMode()
                }
                .spacing(.sm)
                .secondaryButton()
            }
            .spacing(.md)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.7), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
            )
            
            Spacer()
            
            // Bottom Navigation (Page Mode Only)
            if presentationModel.isPageMode {
                HStack {
                    Button("이전") {
                        onPreviousPage()
                    }
                    .disabled(!presentationModel.hasPreviousPage)
                    .spacing(.md)
                    .secondaryButton()
                    .opacity(presentationModel.previousButtonOpacity)
                    
                    Spacer()
                    
                    Text(presentationModel.pageIndicatorText)
                        .typography(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.md.value)
                        .padding(.vertical, Spacing.sm.value)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(.medium)
                    
                    Spacer()
                    
                    Button("다음") {
                        onNextPage()
                    }
                    .disabled(!presentationModel.hasNextPage)
                    .spacing(.md)
                    .secondaryButton()
                    .opacity(presentationModel.nextButtonOpacity)
                }
                .spacing(.md)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
}
