import SwiftUI
import UI

// MARK: - Search Bar
struct SearchBarView: View {
    @Binding var text: String
    private let presentationModel = SearchBarPresentationModel()
    
    var body: some View {
        HStack {
            Image(systemName: presentationModel.iconName)
                .foregroundColor(.textSecondary)
            
            TextField(presentationModel.placeholderText, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .spacing(.md)
        .background(Color.cardBackgroundColor)
        .cornerRadius(.medium)
    }
}
