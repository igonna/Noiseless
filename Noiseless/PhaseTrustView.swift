import SwiftUI

struct PhaseTrustView: View {
    @EnvironmentObject var model: OnboardingModel
    @State private var identityDetailInput: String = ""

    var body: some View {
        Group {
            if model.currentStep == .welcome {
                welcomeView
            } else if model.currentStep == .identity {
                identityView
            } else if model.currentStep == .identityDetails {
                identityDetailsView
            }
        }
    }
    
    // Screen 1: Welcome
    var welcomeView: some View {
        StepLayout(showProgressBar: false, centerContent: true, hideBackButton: true) {
            ZStack {
                // Glow effect
                GlowView()
                
                VStack(spacing: 32) {
                    // Logo placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.white.opacity(0.1), radius: 20, x: 0, y: 10)
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: 40, height: 40)
                    }
                    .padding(.bottom, 24)
                    
                    Text("Let’s accelerate your growth.")
                        .font(.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text("Daily insights. Smarter choices. Better outcomes.")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.zinc400)
                        .frame(maxWidth: 300)
                    
                    Spacer()
                    
                    PrimaryButton(title: "Get Started") {
                        model.nextStep()
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    struct GlowView: View {
        @State private var isAnimating = false
        
        var body: some View {
            Circle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color.zinc800, Color.zinc500]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 256, height: 256)
                .blur(radius: 60)
                .opacity(isAnimating ? 0.2 : 0.1)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
        }
    }
    
    // Screen 2: Identity Fork
    var identityView: some View {
        let identities: [(id: String, label: String, icon: String)] = [
            ("pro", "Working professional", "identity_working_professional"),
            ("student", "Student or learner", "identity_student"),
            ("career_change", "Changing careers", "identity_career_change"),
            ("freelance", "Freelancer / self-employed", "identity_freelancer"),
            ("figuring", "Figuring things out", "identity_figuring"),
            ("improving", "Just improving myself", "identity_improving")
        ]
        
        return StepLayout(title: "Which describes you best?") {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(identities, id: \.id) { item in
                        IconOptionButton(title: item.label, iconName: item.icon, useSystemIcon: false) {
                            HapticManager.tap()
                            model.updateUserData(PartialUserData(identity: item.label))
                            model.nextStep()
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 2)
            }
        }
    }
    
    // Screen 3: Identity Details
    var identityDetailsView: some View {
        let identity = model.userData.identity
        var title = ""
        var placeholder = ""
        var options: [String] = []
        var isDirectInput = false

        if identity == "Working professional" {
            title = "What's your current role?"
            placeholder = "Type your role…"
            isDirectInput = true
        } else if identity == "Student or learner" {
            title = "What are you studying or learning?"
            options = ["Programming", "Engineering", "Business", "Finance", "Design", "Marketing", "AI / Machine Learning", "Data Science", "Psychology", "Health & Fitness", "Languages"]
            placeholder = "e.g. Astrophysics..."
        } else if identity == "Changing careers" {
            title = "What are you transitioning toward?"
            options = ["Tech / engineering", "Design", "Business / management", "Marketing", "Product", "Freelancing", "Entrepreneurship", "AI / ML", "Data", "Creative fields"]
            placeholder = "Describe your target career..."
        } else if identity == "Freelancer / self-employed" {
            title = "What type of work do you do?"
            options = ["Software", "Design", "Marketing", "Consulting", "Coaching", "Content creation", "Sales", "Service work"]
            placeholder = "Describe your work..."
        } else {
            title = "What are you curious about right now?"
            options = ["AI & future tech", "Starting a business", "Earning more money", "Developing discipline", "Improving health", "Finding direction", "Creativity & art", "Personal development", "Relationships & social skills", "Learning new skills"]
            placeholder = "What are you curious about?"
        }

        // Direct Input Case - Still custom since SelectionScreen doesn't support direct text input
        if isDirectInput {
            return AnyView(
                StepLayout(title: title) {
                    VStack(alignment: .leading, spacing: 24) {
                        InlineApplyTextField(
                            placeholder: placeholder,
                            text: $identityDetailInput,
                            autoFocus: true
                        ) { value in
                            applyIdentityDetail(with: value)
                        }

                        Spacer()

                        BottomActionSection(
                            buttonDisabled: trimmedIdentityDetail.isEmpty
                        ) {
                            submitIdentityDetail()
                        }
                    }
                }
                .onAppear {
                    identityDetailInput = model.userData.identityDetail
                }
            )
        }

        // Options Selection Case - Use SelectionScreen for consistency
        return AnyView(
            IdentityDetailsSelectionScreen(
                title: title,
                options: options,
                selected: model.userData.identityDetail,
                onSelect: { newValue in
                    model.updateUserData(PartialUserData(identityDetail: newValue))
                },
                onNext: { model.nextStep() },
                placeholder: placeholder
            )
        )
    }
    
    private func submitIdentityDetail() {
        let trimmed = trimmedIdentityDetail
        guard !trimmed.isEmpty else { return }
        applyIdentityDetail(with: trimmed, triggerHaptic: false)
        model.nextStep()
    }
}

extension PhaseTrustView {
    private var trimmedIdentityDetail: String {
        identityDetailInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func applyIdentityDetail(with value: String? = nil, triggerHaptic: Bool = true) {
        let inputValue = value ?? trimmedIdentityDetail
        let trimmed = inputValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        model.updateUserData(PartialUserData(identityDetail: trimmed))
        identityDetailInput = trimmed
        if triggerHaptic {
            HapticManager.lightTap()
        }
    }
}

// Specialized selection screen for identity details (single selection)
struct IdentityDetailsSelectionScreen: View {
    let title: String
    let options: [String]
    let selected: String
    let onSelect: (String) -> Void
    let onNext: () -> Void
    let placeholder: String

    @State private var isAdding: Bool = false
    @State private var customInput: String = ""
    @FocusState private var addFieldFocused: Bool

    var body: some View {
        // Merge default options with the selected option if it's custom
        let isCustom = !selected.isEmpty && !options.contains(selected)
        let displayOptions = isCustom ? options + [selected] : options

        return StepLayout(title: title) {
            VStack(alignment: .leading, spacing: 0) {
                if !isAdding {
                    ScrollView(showsIndicators: false) {
                        FlowLayout(spacing: 12) {
                            ForEach(displayOptions, id: \.self) { option in
                                OptionButton(
                                    label: option,
                                    selected: selected == option
                                ) {
                                    onSelect(option)
                                }
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
            onSelect(val)
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
