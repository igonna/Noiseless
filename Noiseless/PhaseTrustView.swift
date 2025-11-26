import SwiftUI

struct PhaseTrustView: View {
    @EnvironmentObject var model: OnboardingModel
    @State private var showOtherInput: Bool = false
    @State private var customInput: String = ""
    
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
        StepLayout(showProgressBar: false, centerContent: true) {
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
            ("pro", "Working professional", "briefcase"),
            ("student", "Student or learner", "graduationcap"),
            ("career_change", "Changing careers", "arrow.triangle.2.circlepath"),
            ("freelance", "Freelancer / self-employed", "laptopcomputer"),
            ("figuring", "Figuring things out", "questionmark.circle"),
            ("improving", "Just improving myself", "person")
        ]
        
        return StepLayout(title: "Which describes you best?") {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(identities, id: \.id) { item in
                        OptionButton(
                            label: item.label,
                            icon: item.icon,
                            selected: false // Single selection, immediate next step
                        ) {
                            model.updateUserData(PartialUserData(identity: item.label))
                            model.nextStep()
                        }
                    }
                }
                .padding(.vertical, 8)
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
            title = "What’s your current role?"
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
        
        // Direct Input Case
        if isDirectInput {
            return AnyView(
                StepLayout(title: title) {
                    VStack {
                        TextField(placeholder, text: $model.userData.identityDetail)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .overlay(Rectangle().frame(height: 1).padding(.top, 35).foregroundColor(.zinc800), alignment: .bottom)
                            .accentColor(.white)
                        
                        Spacer()
                        
                        PrimaryButton(title: "Continue", disabled: model.userData.identityDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                            model.nextStep()
                        }
                        .padding(.bottom, 20)
                    }
                }
            )
        }
        
        // Options Selection Case
        let currentSelected = model.userData.identityDetail
        let isCustom = !currentSelected.isEmpty && !options.contains(currentSelected)
        let displayOptions = isCustom ? options + [currentSelected] : options
        
        return AnyView(
            StepLayout(title: title) {
                VStack {
                    if !showOtherInput {
                        ScrollView(showsIndicators: false) {
                            // Using LazyVGrid for wrapping layout equivalent
                            FlowLayout(spacing: 12) {
                                ForEach(displayOptions, id: \.self) { option in
                                    Button(action: {
                                        model.updateUserData(PartialUserData(identityDetail: option))
                                    }) {
                                        Text(option)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(currentSelected == option ? .white : .zinc200)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(currentSelected == option ? Color.zinc800 : Color.zinc900.opacity(0.5))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(currentSelected == option ? Color.zinc500 : Color.zinc800.opacity(0.5), lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        showOtherInput = true
                                        customInput = ""
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 14))
                                        Text("Add")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.zinc400)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.zinc800.opacity(0.5), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Spacer()
                        
                        PrimaryButton(title: "Continue", disabled: model.userData.identityDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                            model.nextStep()
                        }
                        .padding(.bottom, 20)
                        
                    } else {
                        // Custom Input View
                        VStack(alignment: .leading) {
                            Button(action: {
                                withAnimation {
                                    showOtherInput = false
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
                                    if !customInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        model.updateUserData(PartialUserData(identityDetail: customInput))
                                        withAnimation {
                                            showOtherInput = false
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                            PrimaryButton(title: "Add Option", disabled: customInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                                model.updateUserData(PartialUserData(identityDetail: customInput))
                                withAnimation {
                                    showOtherInput = false
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        )
    }
}

