import SwiftUI
import UIKit

enum PrimaryButtonStyle {
    case primary
    case secondary
    case ghost
}

struct PrimaryButton: View {
    let title: String
    var disabled: Bool = false
    var variant: PrimaryButtonStyle = .primary
    var fullWidth: Bool = true
    var height: CGFloat = 56
    var fontSize: CGFloat = 16
    var iconSystemName: String? = nil
    var enableHaptics: Bool = true
    var enablePressAnimation: Bool = false
    let action: () -> Void

    init(
        title: String,
        disabled: Bool = false,
        variant: PrimaryButtonStyle = .primary,
        fullWidth: Bool = true,
        height: CGFloat = 56,
        fontSize: CGFloat = 16,
        iconSystemName: String? = nil,
        enableHaptics: Bool = true,
        enablePressAnimation: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.disabled = disabled
        self.variant = variant
        self.fullWidth = fullWidth
        self.height = height
        self.fontSize = fontSize
        self.iconSystemName = iconSystemName
        self.enableHaptics = enableHaptics
        self.enablePressAnimation = enablePressAnimation
        self.action = action
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .primary: return .white
        case .secondary: return .zinc900
        case .ghost: return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .primary: return .black
        case .secondary: return .white
        case .ghost: return .zinc400
        }
    }
    
    private var borderColor: Color? {
        switch variant {
        case .primary: return nil
        case .secondary: return Color.zinc700
        case .ghost: return Color.zinc700
        }
    }
    
    private var shadowColor: Color {
        switch variant {
        case .primary: return Color.white.opacity(0.15)
        case .secondary: return Color.black.opacity(0.45)
        case .ghost: return Color.clear
        }
    }
    
    var body: some View {
        Button(action: triggerAction) {
            HStack(spacing: 8) {
                if let iconSystemName {
                    Image(systemName: iconSystemName)
                        .font(.system(size: fontSize, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: fontSize, weight: .bold))
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: height)
            .background(backgroundColor)
            .overlay(
                Capsule()
                    .stroke(borderColor ?? Color.clear, lineWidth: borderColor == nil ? 0 : 1)
            )
            .cornerRadius(height / 2)
            .shadow(color: shadowColor, radius: 15, x: 0, y: 0)
            .opacity(disabled ? 0.5 : 1.0)
        }
        .buttonStyle(enablePressAnimation ? AnyButtonStyle(PressScaleButtonStyle()) : AnyButtonStyle(NoAnimationButtonStyle()))
        .disabled(disabled)
    }

    private func triggerAction() {
        guard !disabled else { return }
        if enableHaptics {
            if variant == .primary {
                HapticManager.trigger(.impact(.soft))
            } else {
                HapticManager.trigger(.selection)
            }
        }
        action()
    }
}

struct OptionButton: View {
    let label: String
    var icon: String? = nil // SF Symbol name
    var selected: Bool = false
    var isAdd: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: triggerInstantAction) {
            HStack(spacing: 8) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(selected ? .black : (isAdd ? .zinc500 : .zinc400))
                }

                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selected ? .black : (isAdd ? .zinc500 : .zinc400))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        selected ? Color.white : (isAdd ? Color.clear : Color.zinc900.opacity(0.8))
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                selected ? Color.white : (isAdd ? Color.zinc800 : Color.zinc800.opacity(0.8)),
                                lineWidth: 1
                            )
                    )
            )
            .contentShape(Capsule())
        }
        .buttonStyle(NoAnimationButtonStyle())
        .transaction { transaction in
            transaction.animation = nil
            transaction.disablesAnimations = true
        }
        .animation(nil, value: selected)
    }

    private func triggerInstantAction() {
        triggerActionWithHaptic()
    }

    private func triggerActionWithHaptic() {
        HapticManager.lightTap()
        withAnimation(nil) {
            action()
        }
    }
}

struct InlineApplyTextField: View {
    let placeholder: String
    @Binding var text: String
    var fontSize: CGFloat = 24
    var textColor: Color = .white
    var underlineColor: Color = .zinc800
    var autoFocus: Bool = false
    let onApply: (String) -> Void

    @FocusState private var isFocused: Bool

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: $text)
                .font(.system(size: fontSize))
                .foregroundColor(textColor)
                .padding(.vertical, 12)
                .padding(.trailing, isFocused ? 60 : 0)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(underlineColor)
                }
                .accentColor(.white)
                .focused($isFocused)
                .onSubmit(applyIfNeeded)

            if isFocused {
                Button(action: applyIfNeeded) {
                    Text("Apply")
                        .font(.system(size: 14))
                        .foregroundColor(trimmedText.isEmpty ? .zinc700 : .zinc500)
                        .padding(.leading, 16)
                        .padding(.vertical, 12)
                }
                .contentShape(Rectangle())
                .disabled(trimmedText.isEmpty)
                .opacity(trimmedText.isEmpty ? 0.2 : 1)
            }
        }
        .onAppear {
            if autoFocus {
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
        }
    }

    private func applyIfNeeded() {
        let value = trimmedText
        guard !value.isEmpty else { return }
        text = value
        onApply(value)
        isFocused = false
    }
}

struct NoAnimationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

struct IconOptionButton: View {
    let title: String
    var subtitle: String? = nil
    let iconName: String
    var showSelectionIndicator: Bool = false
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.zinc200)
                    .frame(width: 48, height: 48)
                    .background(Color.zinc800)
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.zinc200)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.zinc500)
                    }
                }

                Spacer()

                if showSelectionIndicator {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .zinc600)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.zinc900.opacity(showSelectionIndicator && isSelected ? 0.85 : 0.65))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(showSelectionIndicator && isSelected ? Color.white : Color.zinc800.opacity(0.8), lineWidth: 1)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct StepLayout<Content: View>: View {
    let title: String?
    let subtitle: String?
    let showProgressBar: Bool
    let centerContent: Bool
    let hideBackButton: Bool
    let centerTitle: Bool
    let content: () -> Content

    @EnvironmentObject var model: OnboardingModel

    init(
        title: String? = nil,
        subtitle: String? = nil,
        showProgressBar: Bool = true,
        centerContent: Bool = false,
        hideBackButton: Bool = false,
        centerTitle: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showProgressBar = showProgressBar
        self.centerContent = centerContent
        self.hideBackButton = hideBackButton
        self.centerTitle = centerTitle
        self.content = content
    }

    private var headingAlignment: TextAlignment {
        (centerContent || centerTitle) ? .center : .leading
    }

    private var stackAlignment: HorizontalAlignment {
        centerContent ? .center : .leading
    }

    private var contentTopPadding: CGFloat {
        72
    }

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                Color.zinc950
                    .ignoresSafeArea()

                VStack(alignment: stackAlignment, spacing: 16) {
                    if let title = title {
                        Text(title)
                            .font(.system(size: 32, weight: .bold))
                            .tracking(-0.5)
                            .foregroundColor(.white)
                            .multilineTextAlignment(headingAlignment)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: centerContent ? .center : .leading)
                    }

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 18))
                            .foregroundColor(.zinc400)
                            .multilineTextAlignment(headingAlignment)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: centerContent ? .center : .leading)
                    }

                    content()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: centerContent ? .center : .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, contentTopPadding)
                .padding(.bottom, 0)
            }
        }
    }
}

// Shared bottom section component for consistent button positioning
struct BottomActionSection: View {
    let buttonTitle: String
    let buttonDisabled: Bool
    let showDivider: Bool
    let action: () -> Void

    init(
        buttonTitle: String = "Continue",
        buttonDisabled: Bool = false,
        showDivider: Bool = true,
        action: @escaping () -> Void
    ) {
        self.buttonTitle = buttonTitle
        self.buttonDisabled = buttonDisabled
        self.showDivider = showDivider
        self.action = action
    }

    var body: some View {
        VStack(spacing: 0) {
            if showDivider {
                Divider()
                    .background(Color.zinc900)
                    .padding(.bottom, 16)
            }

            PrimaryButton(title: buttonTitle, disabled: buttonDisabled) {
                action()
            }
        }
        .padding(.bottom, 10)
        .background(Color.zinc950)
    }
}

// Layout wrapper for scrollable content with fixed button at bottom
struct ScrollableContentLayout<Content: View>: View {
    let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                content()
                    .padding(.vertical, 8)
            }

            Spacer(minLength: 0)
        }
    }
}

struct ProgressBar: View {
    let currentStep: ScreenStep
    
    var progress: Double {
        let total = Double(ScreenStep.allCases.count)
        let current = Double(currentStep.rawValue)
        return min((current / total), 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.zinc900)
                    .frame(height: 6) // React: h-1.5 (6px)
                
                Capsule()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * progress, height: 6)
                    .animation(.linear(duration: 0.3), value: progress)
            }
        }
        .frame(height: 6)
    }
}

// Color Extensions
extension Color {
    static let zinc100 = Color(red: 0.95, green: 0.95, blue: 0.96)
    static let zinc200 = Color(red: 0.898, green: 0.898, blue: 0.918)
    static let zinc300 = Color(red: 0.82, green: 0.82, blue: 0.84)
    static let zinc400 = Color(red: 0.635, green: 0.635, blue: 0.667)
    static let zinc500 = Color(red: 0.451, green: 0.451, blue: 0.478)
    static let zinc600 = Color(red: 0.32, green: 0.32, blue: 0.34)
    static let zinc700 = Color(red: 0.24, green: 0.24, blue: 0.26)
    static let zinc800 = Color(red: 0.149, green: 0.149, blue: 0.153)
    static let zinc900 = Color(red: 0.094, green: 0.094, blue: 0.098)
    static let zinc950 = Color(red: 0.035, green: 0.035, blue: 0.039)
}

// Simple FlowLayout implementation for SwiftUI
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.last?.maxY ?? 0
        let width = proposal.width ?? defaultWidth
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        
        for row in rows {
            for element in row.elements {
                element.subview.place(at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + element.y), proposal: .unspecified)
            }
        }
    }
    
    struct Row {
        var elements: [Element] = []
        var maxY: CGFloat = 0
    }
    
    struct Element {
        var subview: LayoutSubview
        var x: CGFloat
        var y: CGFloat
    }
    
    func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeightInRow: CGFloat = 0
        
        let maxWidth = proposal.width ?? defaultWidth
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > maxWidth && !currentRow.elements.isEmpty {
                // New row
                currentRow.maxY = y + maxHeightInRow
                rows.append(currentRow)
                currentRow = Row()
                x = 0
                y += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            
            currentRow.elements.append(Element(subview: subview, x: x, y: y))
            x += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }
        
        if !currentRow.elements.isEmpty {
            currentRow.maxY = y + maxHeightInRow
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private var defaultWidth: CGFloat {
        max(UIScreen.main.bounds.width - 48, 0)
    }
}
