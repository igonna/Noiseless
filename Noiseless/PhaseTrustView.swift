import SwiftUI

struct PhaseTrustView: View {
    @EnvironmentObject var model: OnboardingModel
    @EnvironmentObject var authController: AuthController
    @State private var identityDetailInput: String = ""
    @State private var showSignIn = false

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

                    Text("Let's accelerate your growth.")
                        .font(.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)

                    Text("Daily insights. Smarter choices. Better outcomes.")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.zinc400)
                        .frame(maxWidth: 300)

                    Spacer()

                    VStack(spacing: 16) {
                        PrimaryButton(title: "Get Started") {
                            model.nextStep()
                        }

                        Button(action: {
                            showSignIn = true
                        }) {
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .font(.system(size: 15))
                                    .foregroundColor(.zinc400)
                                Text("Sign in")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInSheet()
                .environmentObject(authController)
                .environmentObject(model)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
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

// MARK: - Sign In Sheet

private struct SignInSheet: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var model: OnboardingModel
    @Environment(\.dismiss) var dismiss
    @State private var showEmailSignIn = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.zinc950.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Sign in to your account")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text("Access your personalized insights and progress")
                            .font(.system(size: 15))
                            .foregroundColor(.zinc400)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    Spacer()

                    // Sign in options
                    VStack(spacing: 16) {
                        SignInButton(
                            style: .apple,
                            isLoading: authController.isAuthenticating && authController.activeProvider == .apple,
                            action: {
                                authController.signIn(with: .apple)
                            },
                            customLabel: "Sign in with Apple"
                        )
                        SignInButton(
                            style: .email,
                            isLoading: authController.isAuthenticating && authController.activeProvider == .email,
                            action: {
                                showEmailSignIn = true
                            }
                        )
                    }
                    .padding(.horizontal, 12)

                    Spacer()

                    VStack(spacing: 8) {
                        Text("We'll sync your data securely.")
                            .font(.system(size: 12))
                            .foregroundColor(.zinc600)

                        if let errorMessage = authController.lastErrorMessage {
                            Text(errorMessage)
                                .font(.system(size: 11))
                                .foregroundColor(.red.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.zinc400)
                }
            }
        }
        .onChange(of: authController.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                handleAuthentication()
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInSheet()
                .environmentObject(authController)
        }
        .onAppear {
            // If already authenticated, skip to dashboard immediately
            if authController.isAuthenticated {
                handleAuthentication()
            }
        }
    }

    private func handleAuthentication() {
        showEmailSignIn = false
        // Skip to dashboard since user is signed in
        hasCompletedOnboarding = true
        dismiss()
    }
}

// MARK: - Email Sign In Sheet (Reused from PhaseValueView)

private struct EmailSignInSheet: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var magicLinkSent = false
    @State private var isCheckingAuth = false
    @State private var checkTimer: Timer?
    @State private var validationError: String?
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color.zinc950.ignoresSafeArea()

                VStack(spacing: 0) {
                    if magicLinkSent {
                        // Waiting for verification state
                        VStack(spacing: 16) {
                            Spacer()

                            Image(systemName: "envelope.badge.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.green)
                                .padding(.bottom, 16)

                            Text("Check your email")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)

                            Text("We've sent a magic login link to:")
                                .font(.system(size: 14))
                                .foregroundColor(.zinc400)

                            Text(email)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.bottom, 16)

                            Spacer()

                            // Resend button
                            Button(action: handleResend) {
                                HStack(spacing: 6) {
                                    Text("Didn't get it?")
                                        .font(.system(size: 13))
                                        .foregroundColor(.zinc500)
                                    Text("Resend link")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        // Email input state
                        Spacer()

                        VStack(spacing: 20) {
                            Text("We'll send a verification link to your email")
                                .font(.system(size: 15))
                                .foregroundColor(.zinc400)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 4)

                            TextField("Email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .focused($isEmailFocused)
                                .onChange(of: email) { _ in
                                    validationError = nil
                                }

                            Button {
                                handleSubmit()
                            } label: {
                                Group {
                                    if authController.isAuthenticating {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .zinc950))
                                    } else {
                                        Text("Send Magic Link")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.zinc950)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .cornerRadius(28)
                            }
                            .buttonStyle(.plain)
                            .disabled(authController.isAuthenticating || email.isEmpty)
                            .opacity((authController.isAuthenticating || email.isEmpty) ? 0.5 : 1.0)

                            if let errorMessage = validationError {
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            } else if let errorMessage = authController.lastErrorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }

                        Spacer()
                    }
                }
                .padding(24)
            }
            .navigationTitle("Continue with Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        stopCheckingAuth()
                        dismiss()
                    }
                    .foregroundColor(.zinc400)
                }
            }
            .onDisappear {
                stopCheckingAuth()
            }
            .onAppear {
                isEmailFocused = true
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func handleSubmit() {
        // Validate email format
        guard isValidEmail(email) else {
            validationError = "Please enter a valid email address"
            return
        }

        Task {
            let success = await authController.signInWithMagicLink(email: email)
            if success {
                magicLinkSent = true
                startCheckingAuth()
            }
        }
    }

    private func handleResend() {
        Task {
            await authController.signInWithMagicLink(email: email)
        }
    }

    private func startCheckingAuth() {
        isCheckingAuth = true
        checkTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task {
                await checkAuthStatus()
            }
        }
    }

    private func stopCheckingAuth() {
        checkTimer?.invalidate()
        checkTimer = nil
        isCheckingAuth = false
    }

    private func checkAuthStatus() async {
        if authController.isAuthenticated {
            await MainActor.run {
                stopCheckingAuth()
                dismiss()
            }
        }
    }
}

private struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.zinc900)
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.zinc700, lineWidth: 1)
            )
    }
}

private struct SignInButton: View {
    enum Style {
        case apple
        case email
    }

    let style: Style
    let isLoading: Bool
    let action: () -> Void
    var customLabel: String? = nil

    private var label: String {
        if let customLabel = customLabel {
            return customLabel
        }
        switch style {
        case .apple: return "Continue with Apple"
        case .email: return "Continue with Email"
        }
    }

    private var background: Color {
        switch style {
        case .apple: return .white
        case .email: return Color.zinc900
        }
    }

    private var foreground: Color {
        style == .apple ? .black : .white
    }

    private var borderColor: Color {
        style == .apple ? Color.clear : Color.zinc700
    }

    var body: some View {
        Button(action: triggerAction) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foreground))
                        .frame(width: 24, height: 24)
                } else {
                    icon
                }
                Text(label)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 1)
            )
            .cornerRadius(28)
            .shadow(color: style == .apple ? Color.white.opacity(0.2) : Color.black.opacity(0.4), radius: 15, x: 0, y: 0)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }

    private func triggerAction() {
        HapticManager.tap()
        action()
    }

    @ViewBuilder
    private var icon: some View {
        switch style {
        case .apple:
            Image("apple_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
                .offset(y: -2)
        case .email:
            Image(systemName: "envelope.fill")
                .font(.system(size: 20))
        }
    }
}
