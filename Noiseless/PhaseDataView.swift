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
                            withAnimation {
                                isEditingLocation = true
                            }
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
                        ZStack(alignment: .trailing) {
                            TextField("Enter city...", text: $locationQuery)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .overlay(Rectangle().frame(height: 1).padding(.top, 35).foregroundColor(.zinc800), alignment: .bottom)
                                .accentColor(.white)
                                .onSubmit {
                                    if !locationQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        model.updateUserData(PartialUserData(location: locationQuery))
                                        model.nextStep()
                                    }
                                }
                            
                            Button("Cancel") {
                                withAnimation {
                                    isEditingLocation = false
                                }
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.zinc500)
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
                    
                    PrimaryButton(title: "Confirm", disabled: locationQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                        model.updateUserData(PartialUserData(location: locationQuery))
                        model.nextStep()
                    }
                }
                .padding(.bottom, 20)
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
        StepLayout(title: "People who stay informed grow faster.", subtitle: "The right insights at the right time create long-term momentum.") {
            GraphContent()
        }
    }
    
    struct GraphContent: View {
        @EnvironmentObject var model: OnboardingModel
        @State private var pathProgress: CGFloat = 0.0
        @State private var nodeOpacity: Double = 0.0
        @State private var nodeScale: CGFloat = 0.0
        
        var body: some View {
            VStack {
                Spacer()
                
                // Graph Container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.zinc900.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                    
                    // Grid
                    VStack(spacing: 0) {
                        ForEach(0..<6) { _ in
                            Divider().background(Color.zinc800.opacity(0.5))
                            Spacer()
                        }
                    }
                    .padding(.vertical, 16)
                    
                    HStack(spacing: 0) {
                        ForEach(0..<6) { _ in
                            Divider().background(Color.zinc800.opacity(0.5))
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Lines (Simulated with Shapes)
                    GeometryReader { geo in
                        // Dashed Line (Linear)
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: geo.size.height))
                            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.3))
                        }
                        .trim(from: 0, to: pathProgress)
                        .stroke(Color.zinc500, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        
                        // Curved Line (Exponential)
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: geo.size.height))
                            path.addCurve(
                                to: CGPoint(x: geo.size.width, y: 0),
                                control1: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.8),
                                control2: CGPoint(x: geo.size.width * 0.8, y: geo.size.height * 0.4)
                            )
                        }
                        .trim(from: 0, to: pathProgress)
                        .stroke(Color.blue, lineWidth: 3)
                        
                        // Glowing Node
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                            .shadow(color: Color.blue, radius: 10, x: 0, y: 0)
                            .position(x: geo.size.width, y: 0)
                            .opacity(nodeOpacity)
                            .scaleEffect(nodeScale)
                    }
                    .padding(20) // Inset for graph drawing
                    
                    // Labels
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Without Guidance")
                                .font(.system(size: 12))
                                .foregroundColor(.zinc500)
                                .padding(6)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(4)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.zinc800, lineWidth: 1))
                        }
                        .padding(.bottom, 40)
                        .padding(.trailing, 16)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Text("With Personalized Insights")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(6)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(4)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                        }
                        .padding(.top, 32)
                        .padding(.trailing, 16)
                        Spacer()
                    }
                }
                .frame(height: 256)
                .padding(.vertical, 24)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.5)) {
                        pathProgress = 1.0
                    }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.5)) {
                        nodeOpacity = 1.0
                        nodeScale = 1.0
                    }
                }
                
                Spacer()
                
                PrimaryButton(title: "Continue") {
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // Screen 8: Vision
    var visionView: some View {
        let visionOptions: [(label: String, icon: String)] = [
            ("More income", "dollarsign.circle"),
            ("Learn powerful skills", "bolt"),
            ("More freedom", "wind"),
            ("Start a business", "rocket"),
            ("More discipline", "target"),
            ("Better well-being", "heart"),
            ("Multiple income streams", "square.stack.3d.up"),
            ("Find clarity", "lightbulb"),
            ("New career path", "safari")
        ]
        
        return StepLayout(title: "What do you want to achieve?", subtitle: "Select up to 3") {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(visionOptions, id: \.label) { item in
                        let isSelected = model.userData.vision.contains(item.label)
                        let isMaxReached = !isSelected && model.userData.vision.count >= 3
                        
                        Button(action: {
                            var current = model.userData.vision
                            if isSelected {
                                current.removeAll { $0 == item.label }
                            } else if current.count < 3 {
                                current.append(item.label)
                            }
                            model.updateUserData(PartialUserData(vision: current))
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(isSelected ? .black : .zinc200)
                                    .padding(8)
                                    .background(isSelected ? Color.white : Color.zinc800)
                                    .cornerRadius(8)
                                
                                Text(item.label)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(isSelected ? .white : .zinc200)
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? Color.zinc800 : (isMaxReached ? Color.zinc900.opacity(0.2) : Color.zinc900.opacity(0.5)))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelected ? Color.zinc500 : Color.zinc800.opacity(0.5), lineWidth: 1)
                                    )
                                    .shadow(color: isSelected ? Color.white.opacity(0.05) : Color.clear, radius: 15, x: 0, y: 0)
                            )
                            .opacity(isMaxReached ? 0.5 : 1.0)
                        }
                        .disabled(isMaxReached)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            PrimaryButton(title: "Continue", disabled: model.userData.vision.isEmpty) {
                model.nextStep()
            }
            .padding(.bottom, 20)
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
    
    var body: some View {
        // Merge default options with any selected options that aren't in the default list
        let displayOptions = (options + selected.filter { !options.contains($0) }).removingDuplicates()
        
        return StepLayout(title: title, subtitle: subtitle) {
            VStack {
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
                                withAnimation {
                                    isAdding = true
                                    customInput = ""
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Spacer()
                    
                    PrimaryButton(title: "Continue", disabled: selected.isEmpty) {
                        onNext()
                    }
                    .padding(.bottom, 20)
                    
                } else {
                    VStack(alignment: .leading) {
                        Button(action: {
                            withAnimation {
                                isAdding = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Add new option")
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
            withAnimation {
                isAdding = false
            }
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
                Spacer()
                
                VStack(spacing: 16) {
                    Text(currentOption.label)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .scale))
                        .id("label-\(index)") // Force transition
                    
                    Text("“\(currentOption.desc)”")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.zinc400)
                        .transition(.opacity)
                        .id("desc-\(index)")
                }
                .frame(height: 150)
                .animation(.easeInOut(duration: 0.2), value: index)
                
                Spacer()
                
                VStack(spacing: 24) {
                    Slider(value: $selectedIndex, in: 0...Double(options.count - 1), step: 1)
                        .accentColor(.white)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Text("GENTLE")
                        Spacer()
                        Text("SMART")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.zinc500)
                    .tracking(2)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
                
                PrimaryButton(title: "Continue") {
                    let opt = options[index]
                    model.updateUserData(PartialUserData(timeBudget: "\(opt.label) — \(opt.desc)"))
                    model.nextStep()
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            if !model.userData.timeBudget.isEmpty {
                let currentLabel = model.userData.timeBudget.components(separatedBy: " — ").first ?? ""
                if let idx = options.firstIndex(where: { $0.label == currentLabel }) {
                    selectedIndex = Double(idx)
                }
            }
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}
