import SwiftUI
import Core

// MARK: - Colors
public extension Color {
    static let primaryColor = Color("PrimaryColor", bundle: .module)
    static let secondaryColor = Color("SecondaryColor", bundle: .module)
    static let backgroundColor = Color("BackgroundColor", bundle: .module)
    static let cardBackgroundColor = Color("CardBackgroundColor", bundle: .module)
    static let textPrimary = Color("TextPrimary", bundle: .module)
    static let textSecondary = Color("TextSecondary", bundle: .module)
    static let accent = Color("AccentColor", bundle: .module)
}

// MARK: - Typography
public enum Typography {
    case largeTitle
    case title1
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption1
    case caption2
    
    public var font: Font {
        switch self {
        case .largeTitle:
            return .largeTitle.weight(.bold)
        case .title1:
            return .title.weight(.bold)
        case .title2:
            return .title2.weight(.semibold)
        case .title3:
            return .title3.weight(.semibold)
        case .headline:
            return .headline.weight(.semibold)
        case .body:
            return .body
        case .callout:
            return .callout
        case .subheadline:
            return .subheadline
        case .footnote:
            return .footnote
        case .caption1:
            return .caption
        case .caption2:
            return .caption2
        }
    }
}

// MARK: - Spacing
public enum Spacing {
    case xs // 4
    case sm // 8
    case md // 16
    case lg // 24
    case xl // 32
    case xxl // 48
    
    public var value: CGFloat {
        switch self {
        case .xs: return 4
        case .sm: return 8
        case .md: return 16
        case .lg: return 24
        case .xl: return 32
        case .xxl: return 48
        }
    }
}

// MARK: - Corner Radius
public enum CornerRadius {
    case small // 4
    case medium // 8
    case large // 12
    case extraLarge // 16
    
    public var value: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 8
        case .large: return 12
        case .extraLarge: return 16
        }
    }
}

// MARK: - Shadow
public struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    public static let small = ShadowStyle(
        color: .black.opacity(0.1),
        radius: 2,
        x: 0,
        y: 1
    )
    
    public static let medium = ShadowStyle(
        color: .black.opacity(0.1),
        radius: 4,
        x: 0,
        y: 2
    )
    
    public static let large = ShadowStyle(
        color: .black.opacity(0.15),
        radius: 8,
        x: 0,
        y: 4
    )
}

// MARK: - View Extensions
public extension View {
    func typography(_ style: Typography) -> some View {
        font(style.font)
    }
    
    func spacing(_ spacing: Spacing) -> some View {
        padding(spacing.value)
    }
    
    func cornerRadius(_ radius: CornerRadius) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius.value))
    }
    
    func cardStyle() -> some View {
        background(Color.cardBackgroundColor)
            .cornerRadius(.medium)
            .shadow(
                color: ShadowStyle.medium.color,
                radius: ShadowStyle.medium.radius,
                x: ShadowStyle.medium.x,
                y: ShadowStyle.medium.y
            )
    }
    
    func primaryButton() -> some View {
        background(Color.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(.medium)
            .typography(.headline)
    }
    
    func secondaryButton() -> some View {
        background(Color.secondaryColor)
            .foregroundColor(.textPrimary)
            .cornerRadius(.medium)
            .typography(.headline)
    }
}
