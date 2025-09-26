import SwiftUI
import UI

// MARK: - Episodes Section
struct EpisodesSectionView: View {
    let presentationModel: EpisodesSectionPresentationModel
    let onEpisodeTap: (String) -> Void
    
    init(presentationModel: EpisodesSectionPresentationModel, onEpisodeTap: @escaping (String) -> Void) {
        self.presentationModel = presentationModel
        self.onEpisodeTap = onEpisodeTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md.value) {
            HStack {
                Text("에피소드")
                    .typography(.title3)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(presentationModel.episodeCountText)
                    .typography(.callout)
                    .foregroundColor(.textSecondary)
            }
            .spacing(.md)
            
            if presentationModel.isEmpty {
                EmptyStateView(
                    title: "에피소드가 없습니다",
                    message: "아직 등록된 에피소드가 없습니다.",
                    systemImage: "doc.text"
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: Spacing.sm.value) {
                    ForEach(presentationModel.episodes) { episode in
                        EpisodeRowView(presentationModel: EpisodeRowPresentationModel(episode: episode)) {
                            onEpisodeTap(episode.id)
                        }
                    }
                }
            }
        }
    }
}
