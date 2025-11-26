import SwiftUI

struct PrimaryButton: View {
    let title: String
    var disabled: Bool = false
    var fullWidth: Bool = true
    var height: CGFloat = 56 // Default to match standard, but allow override
    var fontSize: CGFloat = 16
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .bold)) // Bold weight
                .foregroundColor(.black)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: height)
                .background(Color.white)
                .cornerRadius(100) // Fully rounded capsule
                .shadow(color: Color.white.opacity(0.15), radius: 15, x: 0, y: 0) // Glow shadow
                .opacity(disabled ? 0.5 : 1.0)
        }
        .disabled(disabled)
    }
}

struct OptionButton: View {
    let label: String
    var icon: String? = nil // SF Symbol name
    var selected: Bool = false
    var isAdd: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(selected ? .black : (isAdd ? .zinc500 : .zinc400))
                        // React doesn't have background on icon for standard state, only selected has 'text-black'
                        // Wait, React: selected ? 'text-black' : ...
                        // My code: selected ? .black : ...
                        // React wrapper: selected ? 'bg-white' : 'bg-zinc-900'
                }
                
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selected ? .black : (isAdd ? .zinc500 : .zinc400))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(selected ? Color.white : (isAdd ? Color.clear : Color.zinc900))
                    .overlay(
                        Capsule()
                            .stroke(selected ? Color.white : Color.zinc800, lineWidth: 1)
                    )
                    .shadow(color: selected ? Color.white.opacity(0.2) : Color.clear, radius: 15, x: 0, y: 0)
            )
            // Hover effect simulation (scale)
            .scaleEffect(selected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
        }
    }
}

struct StepLayout<Content: View>: View {
    let title: String?
    let subtitle: String?
    let showProgressBar: Bool
    let centerContent: Bool
    let content: () -> Content
    
    @EnvironmentObject var model: OnboardingModel
    
    init(title: String? = nil, subtitle: String? = nil, showProgressBar: Bool = true, centerContent: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.showProgressBar = showProgressBar
        self.centerContent = centerContent
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.035, blue: 0.039) // zinc-950 hex #09090b
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header: Back Button & Progress Bar
                HStack(spacing: 16) {
                    // Back Button Logic
                    if model.currentStep.rawValue > 1 {
                        let isMinimal = model.currentStep == .trialOffer || model.currentStep == .paywall
                        
                        Button(action: {
                            model.prevStep()
                        }) {
                            Image(systemName: isMinimal ? "chevron.left" : "arrow.left")
                                .font(.system(size: isMinimal ? 24 : 20)) // React: 32px vs 24px
                                .foregroundColor(isMinimal ? .zinc500 : .zinc400)
                                .padding(8)
                                // Minimal has no hover bg in React, standard does. SwiftUI buttons don't hover same way.
                                // We'll keep it simple.
                        }
                    } else {
                        Color.clear.frame(width: 40, height: 40)
                    }
                    
                    if showProgressBar {
                        ProgressBar(currentStep: model.currentStep)
                    } else {
                        Spacer()
                    }
                }
                .padding(.horizontal, 24) // React: px-6
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                VStack(alignment: centerContent ? .center : .leading, spacing: 16) {
                    if let title = title {
                        Text(title)
                            .font(.system(size: 32, weight: .bold)) // React: text-3xl md:text-4xl
                            .tracking(-0.5) // React: tracking-tight
                            .foregroundColor(.white)
                            .multilineTextAlignment(centerContent ? .center : .leading)
                            .lineSpacing(4) // React: leading-[1.15]
                    }
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 18)) // React: text-lg
                            .foregroundColor(.zinc400)
                            .multilineTextAlignment(centerContent ? .center : .leading)
                            .lineSpacing(6) // React: leading-relaxed
                    }
                    
                    content()
                }
                .padding(.horizontal, 24) // React: px-6
                .padding(.top, 24) // React: pt-24 (approx 96px, but we have header above, so maybe less padding here relative to header)
                // Actually React has absolute header, so pt-24 is from top of screen.
                // In SwiftUI VStack, we need to adjust.
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: centerContent ? .center : .top)
            }
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
                    .shadow(color: Color.white.opacity(0.5), radius: 5, x: 0, y: 0) // React: shadow-[0_0_10px_rgba(255,255,255,0.5)]
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
        return CGSize(width: proposal.width ?? 0, height: height)
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
        
        let maxWidth = proposal.width ?? 0
        
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
}
