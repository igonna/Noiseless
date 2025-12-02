import SwiftUI

struct PhaseDataView: View {
    @EnvironmentObject var model: OnboardingModel
    @State private var isEditingLocation: Bool = false
    @State private var locationQuery: String = ""
    
    var body: some View {
        Group {
            switch model.currentStep {
            case .location: locationView
            case .skills: skillsView
            case .traits: traitsView
            case .graph: graphView
            case .vision: visionView
            case .values: valuesView
            case .constraints: constraintsView
            case .timeBudget: timeBudgetView
            default: EmptyView()
            }
        }
        .onAppear {
            if locationQuery.isEmpty {
                locationQuery = model.userData.location.isEmpty ? "Los Angeles, US" : model.userData.location
            }
        }
    }
    
    // Screen 4: Location
    var locationView: some View {
        StepLayout(title: "Where are you based?") {
            VStack(spacing: 24) {
                if !isEditingLocation {
                    HStack {
                        HStack(spacing: 16) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.zinc800)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Detected Location")
                                    .font(.system(size: 14))
                                    .foregroundColor(.zinc500)
                                Text(locationQuery)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isEditingLocation = true
                        }) {
                            Text("Change")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.zinc400)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.clear) // Transparent background for tap area
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.zinc800, lineWidth: 0) // Invisible stroke for layout consistency if needed, or just remove
                                )
                        }
                    }
                    .padding(24)
                    .background(Color.zinc900)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                } else {
                    VStack {
                        InlineApplyTextField(
                            placeholder: "Enter city...",
                            text: $locationQuery,
                            autoFocus: true
                        ) { value in
                            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            locationQuery = trimmed
                            model.updateUserData(PartialUserData(location: trimmed))
                            HapticManager.lightTap()
                            isEditingLocation = false
                        }
                    }
                    .padding(.top, 24)
                }


                Spacer()

                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.zinc500)
                        Text("Your information remains private and secure.")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.zinc500)
                            .tracking(0.5)
                    }

                    BottomActionSection(
                        buttonDisabled: locationQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        showDivider: false
                    ) {
                        let trimmed = trimmedLocationQuery
                        guard !trimmed.isEmpty else { return }
                        model.updateUserData(PartialUserData(location: trimmed))
                        locationQuery = trimmed
                        model.nextStep()
                    }
                }
            }
        }
    }
    
    // Screen 5: Skills
    var skillsView: some View {
        let skills = [
            "Strategic Thinking", "Programming", "Design", "Writing",
            "Sales", "Data Analysis", "Leadership", "Public Speaking",
            "Marketing", "Project Management"
        ]
        
        return SelectionScreen(
            title: "Your main skills or strengths?",
            options: skills,
            selected: model.userData.skills,
            onSelect: { newSkills in model.updateUserData(PartialUserData(skills: newSkills)) },
            onNext: { model.nextStep() },
            placeholder: "e.g. negotiation, coding..."
        )
    }
    
    // Screen 6: Traits
    var traitsView: some View {
        let traits = ["Creative", "Analytical", "Ambitious", "Curious", "Introverted", "Organized", "Independent", "Driven", "Calm", "Fast-learner"]
        
        return SelectionScreen(
            title: "Which of these describe you?",
            options: traits,
            selected: model.userData.traits,
            onSelect: { newTraits in model.updateUserData(PartialUserData(traits: newTraits)) },
            onNext: { model.nextStep() },
            placeholder: "e.g. energetic..."
        )
    }
    
    // Screen 7: Graph
    var graphView: some View {
        StepLayout(title: "People who stay informed grow faster.") {
            GraphContent()
        }
    }
    
    struct GraphContent: View {
        @EnvironmentObject var model: OnboardingModel
        @State private var drawProgress: CGFloat = 0.0
        @State private var animationFinished: Bool = false
        
        var body: some View {
            VStack(spacing: 0) {
                DualWaveChart(progress: drawProgress)
                    .frame(height: 250)
                    .padding(.horizontal, 4)
                    .padding(.top, 100)
                
                Spacer(minLength: 36)
                
                PrimaryButton(title: "Continue", disabled: !animationFinished) {
                    model.nextStep()
                }
                .padding(.bottom, 10)
            }
            .onAppear {
                startAnimation()
            }
        }
        
        private func startAnimation() {
            animationFinished = false
            drawProgress = 0
            let duration = 1.6
            
            withAnimation(.easeOut(duration: duration)) {
                drawProgress = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                animationFinished = true
                HapticManager.lightTap()
            }
        }
    }
    
    // Screen 8: Vision
    var visionView: some View {
        let options = VisionGoalOption.sampleOptions
        let maxSelection = 3
        let selected = model.userData.vision
        
        return StepLayout(title: "What do you want to achieve?", subtitle: "Select up to 3") {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(options) { option in
                            let isSelected = selected.contains(option.label)
                            let isMaxReached = !isSelected && selected.count >= maxSelection
                            
                            IconOptionButton(
                                title: option.label,
                                subtitle: option.detail,
                                iconName: option.icon,
                                useSystemIcon: option.useSystemIcon,
                                showSelectionIndicator: true,
                                isSelected: isSelected
                            ) {
                                HapticManager.tap()
                                var current = selected
                                if isSelected {
                                    current.removeAll { $0 == option.label }
                                } else if current.count < maxSelection {
                                    current.append(option.label)
                                }
                                model.updateUserData(PartialUserData(vision: current))
                            }
                            .disabled(isMaxReached)
                            .opacity(isMaxReached ? 0.45 : 1)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 2)
                }

                Spacer(minLength: 0)

                BottomActionSection(buttonDisabled: selected.isEmpty) {
                    model.nextStep()
                }
            }
        }
    }
    
    // Screen 9: Values
    var valuesView: some View {
        let values = ["Freedom", "Mastery", "Money", "Growth", "Health", "Stability", "Creativity", "Impact", "Recognition", "Relationships"]
        
        return SelectionScreen(
            title: "What matters most to you?",
            subtitle: "Pick up to 3",
            options: values,
            selected: model.userData.values,
            onSelect: { newValues in model.updateUserData(PartialUserData(values: newValues)) },
            onNext: { model.nextStep() },
            placeholder: "e.g. Adventure...",
            maxSelection: 3
        )
    }
    
    // Screen 10: Constraints
    var constraintsView: some View {
        let constraints = ["Time", "Money", "Confidence", "Focus", "Burnout", "No clear direction", "Responsibilities", "Health issues", "No major hurdles"]
        
        return SelectionScreen(
            title: "What’s holding you back right now?",
            options: constraints,
            selected: model.userData.constraints,
            onSelect: { newConstraints in model.updateUserData(PartialUserData(constraints: newConstraints)) },
            onNext: { model.nextStep() },
            placeholder: "e.g. Procrastination..."
        )
    }
    
    // Screen 11: Time Budget
var timeBudgetView: some View {
        TimeBudgetScreen()
    }
}

private struct Month1WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct DualWaveChart: View {
    var progress: CGFloat
    private let startBase: CGFloat = 0.85
    private let backgroundColor = Color(red: 0x11/255, green: 0x11/255, blue: 0x13/255)
    private let noiselessColor = Color(red: 0x37/255, green: 0x96/255, blue: 0xEF/255)
    private let traditionalColor = Color(red: 0x52/255, green: 0x52/255, blue: 0x5C/255)
    @State private var month1Visible = false
    @State private var month6Visible = false
    @State private var statsVisible = false

    private var normalizedProgress: CGFloat {
        min(max(progress, 0), 1)
    }

    private var noiselessWave: WaveLineConfig {
        WaveLineConfig(
            amplitude: 0.35,
            base: startBase,
            trend: 1.45,
            phase: 0.0,
            curveExponent: 2.2,
            startOffset: 0,
            startOffsetFade: 0
        )
    }

    private var traditionalWave: WaveLineConfig {
        WaveLineConfig(
            amplitude: 0.12,
            base: startBase,
            trend: 0.15,
            phase: 0.0,
            curveExponent: 0.35,
            startOffset: 0.02,
            startOffsetFade: 0.2
        )
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 18, x: 0, y: 10)

            VStack(alignment: .leading, spacing: 18) {
                chartTitle

                legend

                GeometryReader { geo in
                    let markerSize: CGFloat = 12
                    let bottomPadding: CGFloat = 100
                    let chartHeight = geo.size.height - bottomPadding
                    let leftPadding: CGFloat = 0
                    let timelineSpacing: CGFloat = 20
                    let statsBottomPadding: CGFloat = 34

                    ZStack(alignment: .topLeading) {
                        // Gray stagnating line (Traditional)
                        WaveLine(
                            config: traditionalWave,
                            progress: normalizedProgress,
                            containerHeight: chartHeight
                        )
                        .stroke(
                            traditionalColor,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                        )
                        .offset(x: leftPadding)

                        // Blue upward trend line (Noiseless) with glow (on top)
                        WaveLine(
                            config: noiselessWave,
                            progress: normalizedProgress,
                            containerHeight: chartHeight
                        )
                        .stroke(
                            noiselessColor,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: noiselessColor.opacity(0.6), radius: 8, x: 0, y: 0)
                        .shadow(color: noiselessColor.opacity(0.4), radius: 16, x: 0, y: 0)
                        .offset(x: leftPadding)

                        // Bottom section with timeline and stats
                        VStack(alignment: .leading, spacing: timelineSpacing) {
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)

                            HStack {
                                Text("Month 1")
                                    .background(
                                        GeometryReader { textGeo in
                                            Color.clear.preference(
                                                key: Month1WidthKey.self,
                                                value: textGeo.size.width / 2
                                            )
                                        }
                                    )
                                    .opacity(month1Visible ? 1 : 0)
                                    .offset(y: month1Visible ? 0 : 8)
                                    .scaleEffect(month1Visible ? 1 : 0.9, anchor: .leading)
                                Spacer()
                                Text("Month 6")
                                    .opacity(month6Visible ? 1 : 0)
                                    .offset(y: month6Visible ? 0 : 8)
                                    .scaleEffect(month6Visible ? 1 : 0.9, anchor: .trailing)
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                            Text("82% of users achieve faster progress with guided daily insights.")
                                .font(.system(size: 14))
                                .foregroundColor(.zinc400)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, statsBottomPadding)
                                .opacity(statsVisible ? 1 : 0)
                                .offset(y: statsVisible ? 0 : 12)
                                .scaleEffect(statsVisible ? 1 : 0.95)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, chartHeight + 8)
                        .onPreferenceChange(Month1WidthKey.self) { _ in }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .topLeading) {
                        // Start marker positioned at Month 1
                        GeometryReader { overlayGeo in
                            Circle()
                                .fill(backgroundColor)
                                .overlay(
                                    Circle()
                                        .stroke(noiselessColor, lineWidth: 1.4)
                                )
                                .frame(width: markerSize, height: markerSize)
                                .position(
                                    x: leftPadding,
                                    y: chartHeight * startBase
                                )

                            WaveEndMarker(
                                progress: normalizedProgress,
                                markerSize: markerSize,
                                color: noiselessColor,
                                config: noiselessWave,
                                chartHeight: chartHeight,
                                chartWidth: overlayGeo.size.width,
                                leftPadding: leftPadding,
                                backgroundColor: backgroundColor
                            )
                        }
                    }
                }
                .frame(height: 205)
            }
            .padding(24)
        }
        .onAppear {
            initializeTimelineVisibility()
        }
        .onChange(of: normalizedProgress) { newValue in
            updateTimelineVisibility(for: newValue)
        }
    }

    private var chartTitle: some View {
        Text("Your growth")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.white.opacity(0.95))
            .tracking(0.8)
    }

    private var legend: some View {
        HStack(spacing: 20) {
            LegendItem(color: noiselessColor, label: "Noiseless")
            LegendItem(color: traditionalColor, label: "Traditional")
        }
    }
}

private struct WaveLineConfig {
    let amplitude: CGFloat
    let base: CGFloat
    let trend: CGFloat
    let phase: CGFloat
    let curveExponent: CGFloat
    let startOffset: CGFloat
    let startOffsetFade: CGFloat

    func point(for progress: CGFloat, chartHeight: CGFloat, chartWidth: CGFloat, leftPadding: CGFloat) -> CGPoint {
        let clamped = min(max(progress, 0), 1)
        let easedT = curveExponent == 1.0 ? clamped : pow(clamped, curveExponent)
        let usableWidth = max(chartWidth, 0)
        let x = leftPadding + (clamped * usableWidth)
        let wave = sin((clamped + phase) * .pi * 1.5)
        let baseY = chartHeight * base
        let waveOffset = wave * chartHeight * amplitude
        let trendOffset = chartHeight * trend * easedT
        var y = baseY - waveOffset - trendOffset

        if startOffset > 0 {
            let fadeRange = max(startOffsetFade, 0.0001)
            let fadeFactor = max(0, 1 - (clamped / fadeRange))
            let initialOffset = chartHeight * startOffset * fadeFactor
            y += initialOffset
        }

        return CGPoint(x: x, y: y)
    }
}

extension DualWaveChart {
    private func initializeTimelineVisibility() {
        if normalizedProgress > 0 {
            month1Visible = true
        }
        if normalizedProgress >= 0.999 {
            month6Visible = true
            statsVisible = true
        }
    }

    private func updateTimelineVisibility(for value: CGFloat) {
        if value > 0, !month1Visible {
            withAnimation(.easeOut(duration: 0.35)) {
                month1Visible = true
            }
        }

        if value >= 0.995, !month6Visible {
            withAnimation(.easeOut(duration: 0.4)) {
                month6Visible = true
            }
            revealStatsAfterDelay()
        }
    }

    private func revealStatsAfterDelay() {
        guard !statsVisible else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.75)) {
                statsVisible = true
            }
        }
    }
}

private struct WaveEndMarker: View, Animatable {
    var progress: CGFloat
    let markerSize: CGFloat
    let color: Color
    let config: WaveLineConfig
    let chartHeight: CGFloat
    let chartWidth: CGFloat
    let leftPadding: CGFloat
    let backgroundColor: Color

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    private var clampedProgress: CGFloat {
        min(max(progress, 0), 1)
    }

    var body: some View {
        let point = config.point(
            for: clampedProgress,
            chartHeight: chartHeight,
            chartWidth: chartWidth,
            leftPadding: leftPadding
        )

        return ZStack {
            Circle()
                .fill(color.opacity(0.22))
                .frame(width: markerSize * 2.6, height: markerSize * 2.6)
                .blur(radius: 6)

            Circle()
                .fill(backgroundColor)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 1.4)
                )
                .frame(width: markerSize, height: markerSize)
        }
        .opacity(clampedProgress <= 0 ? 0 : 1)
        .position(x: point.x, y: point.y)
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}

private struct WaveLine: Shape {
    var config: WaveLineConfig
    var progress: CGFloat
    var containerHeight: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clampedProgress = min(max(progress, 0), 1)
        guard clampedProgress > 0 else { return path }

        let width = max(rect.width, 1)
        let sampleCount = max(Int(width * 2), 120)
        let step = 1 / CGFloat(sampleCount)

        func point(at t: CGFloat) -> CGPoint {
            config.point(
                for: t,
                chartHeight: containerHeight,
                chartWidth: width,
                leftPadding: 0
            )
        }

        path.move(to: point(at: 0))

        var currentT: CGFloat = step
        while currentT < clampedProgress {
            path.addLine(to: point(at: currentT))
            currentT += step
        }

        path.addLine(to: point(at: clampedProgress))

        return path
    }
}

// Reusable Selection Screen
struct SelectionScreen: View {
    let title: String
    var subtitle: String? = nil
    let options: [String]
    let selected: [String]
    let onSelect: ([String]) -> Void
    let onNext: () -> Void
    var placeholder: String = "Add your own..."
    var multiSelect: Bool = true
    var maxSelection: Int? = nil
    
    @State private var isAdding: Bool = false
    @State private var customInput: String = ""
    @FocusState private var addFieldFocused: Bool
    
    var body: some View {
        // Merge default options with any selected options that aren't in the default list
        let displayOptions = (options + selected.filter { !options.contains($0) }).removingDuplicates()
        
        return StepLayout(title: title, subtitle: subtitle) {
            VStack(alignment: .leading, spacing: 0) {
                if !isAdding {
                    ScrollView(showsIndicators: false) {
                        FlowLayout(spacing: 12) {
                            ForEach(displayOptions, id: \.self) { option in
                                let isSelected = selected.contains(option)
                                let isMaxReached = maxSelection != nil && selected.count >= maxSelection! && !isSelected

                                OptionButton(
                                    label: option,
                                    selected: isSelected
                                ) {
                                    if isSelected {
                                        onSelect(selected.filter { $0 != option })
                                    } else {
                                        if let max = maxSelection, selected.count >= max { return }
                                        if !multiSelect {
                                            onSelect([option])
                                        } else {
                                            onSelect(selected + [option])
                                        }
                                    }
                                }
                                .opacity(isMaxReached ? 0.5 : 1.0)
                                .disabled(isMaxReached)
                            }

                            OptionButton(
                                label: "Add",
                                icon: "plus",
                                isAdd: true
                            ) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isAdding = true
                                    customInput = ""
                                }
                                focusAddFieldSoon()
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 2)
                    }
                    .clipped()

                    Spacer()

                    BottomActionSection(buttonDisabled: selected.isEmpty) {
                        onNext()
                    }
                    .animation(.easeInOut(duration: 0.25), value: isAdding)

                } else {
                    VStack(alignment: .leading) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isAdding = false
                            }
                            addFieldFocused = false
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.left")
                                Text("Add new option")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.zinc400)
                            .padding(.bottom, 16)
                        }
                        
                        TextField(placeholder, text: $customInput)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .overlay(Rectangle().frame(height: 1).padding(.top, 35).foregroundColor(.zinc800), alignment: .bottom)
                            .accentColor(.white)
                            .focused($addFieldFocused)
                            .onSubmit {
                                addCustomOption()
                            }
                        
                        Spacer()
                        
                        PrimaryButton(title: "Add Option", disabled: customInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                            addCustomOption()
                        }
                        .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func addCustomOption() {
        let val = customInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !val.isEmpty {
            if !selected.contains(val) {
                if let max = maxSelection, selected.count >= max, multiSelect {
                    // Ignore if full
                } else {
                    let newSelection = multiSelect ? selected + [val] : [val]
                    onSelect(newSelection)
                }
            }
            withAnimation(.easeInOut(duration: 0.25)) {
                isAdding = false
            }
            addFieldFocused = false
        }
    }

    private func focusAddFieldSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            addFieldFocused = true
        }
    }
}

struct TimeBudgetScreen: View {
    @EnvironmentObject var model: OnboardingModel
    
    let options: [(label: String, desc: String)] = [
        ("Gentle", "Easy, flexible steps."),
        ("Steady", "Solid weekly movement."),
        ("Focused", "Consistent forward momentum."),
        ("Fast", "Accelerated pacing."),
        ("Smart Adapt", "Evolves with you.")
    ]
    
    @State private var selectedIndex: Double = 2.0
    
    var body: some View {
        let index = Int(round(selectedIndex))
        let currentOption = options[index]
        
        return StepLayout(title: "What kind of pace feels right for you?") {
            VStack {
                Spacer(minLength: 0)
                
                VStack(spacing: 12) {
                    Text(currentOption.label)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .scale))
                        .id("label-\(index)")
                    
                    Text("“\(currentOption.desc)”")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.zinc400)
                        .transition(.opacity)
                        .id("desc-\(index)")
                }
                .frame(height: 150)
                .animation(.easeInOut(duration: 0.2), value: index)
                
                VStack(spacing: 16) {
                    LiquidGlassSlider(index: $selectedIndex, steps: options.count)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    HStack {
                        Text("GENTLE")
                        Spacer()
                        Text("SMART")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.zinc500)
                    .tracking(1.5)
                    .padding(.horizontal, 28)
                }
                .padding(.top, 0)
                .padding(.bottom, 20)

                Spacer()

                PrimaryButton(title: "Continue") {
                    model.nextStep()
                }
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            if !model.userData.timeBudget.isEmpty {
                let currentLabel = model.userData.timeBudget.components(separatedBy: " — ").first ?? ""
                if let idx = options.firstIndex(where: { $0.label == currentLabel }) {
                    selectedIndex = Double(idx)
                }
            }
            syncTimeBudget(with: Int(round(selectedIndex)))
        }
        .onChange(of: Int(round(selectedIndex))) { newValue in
            syncTimeBudget(with: newValue)
        }
    }
    
    private func syncTimeBudget(with index: Int) {
        guard options.indices.contains(index) else { return }
        let option = options[index]
        model.updateUserData(PartialUserData(timeBudget: "\(option.label) — \(option.desc)"))
    }
}

extension PhaseDataView {
    private var trimmedLocationQuery: String {
        locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct LiquidGlassSlider: View {
    @Binding var index: Double
    let steps: Int
    
    private var sliderRange: ClosedRange<Double> {
        let maxValue = max(Double(steps - 1), 1)
        return 0...maxValue
    }
    
    var body: some View {
        Slider(
            value: Binding(get: { index }, set: { updateIndex(with: $0) }),
            in: sliderRange,
            step: 1
        )
        .tint(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
    
    private func updateIndex(with newValue: Double) {
        guard steps > 1 else {
            index = 0
            return
        }
        let stepped = min(max(round(newValue), 0), Double(steps - 1))
        guard stepped != index else { return }
        HapticManager.tap()
        withAnimation(.easeInOut(duration: 0.12)) {
            index = stepped
        }
    }
}

struct VisionGoalOption: Identifiable {
    let label: String
    let detail: String?
    let icon: String
    let useSystemIcon: Bool
    var id: String { label }

    init(label: String, detail: String? = nil, icon: String, useSystemIcon: Bool = true) {
        self.label = label
        self.detail = detail
        self.icon = icon
        self.useSystemIcon = useSystemIcon
    }
}

extension VisionGoalOption {
    static let sampleOptions: [VisionGoalOption] = [
        VisionGoalOption(label: "More income", detail: nil, icon: "vision_more_income", useSystemIcon: false),
        VisionGoalOption(label: "Learn powerful skills", detail: nil, icon: "vision_learn_skills", useSystemIcon: false),
        VisionGoalOption(label: "More freedom", detail: nil, icon: "vision_more_freedom", useSystemIcon: false),
        VisionGoalOption(label: "Start a business", detail: nil, icon: "vision_start_business", useSystemIcon: false),
        VisionGoalOption(label: "More discipline", detail: nil, icon: "vision_more_discipline", useSystemIcon: false),
        VisionGoalOption(label: "Better well-being", detail: nil, icon: "vision_better_wellbeing", useSystemIcon: false),
        VisionGoalOption(label: "Multiple income streams", detail: nil, icon: "vision_multiple_income", useSystemIcon: false),
        VisionGoalOption(label: "Find clarity", detail: nil, icon: "vision_find_clarity", useSystemIcon: false),
        VisionGoalOption(label: "New career path", detail: nil, icon: "vision_new_career", useSystemIcon: false)
    ]
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}
