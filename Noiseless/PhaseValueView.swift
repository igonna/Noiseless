import SwiftUI
import Supabase

struct PhaseValueView: View {
    @EnvironmentObject var model: OnboardingModel
    @EnvironmentObject var authController: AuthController

    var body: some View {
        Group {
            switch model.currentStep {
            case .insightsPreview: insightsPreviewView
            case .trialOffer: trialOfferView
            default: EmptyView()
            }
        }
    }

    // Screen 18: Insights Preview
    var insightsPreviewView: some View {
        InsightsPreviewContent()
            .environmentObject(model)
            .environmentObject(authController)
    }
    
    // Screen 19: Trial Offer
    var trialOfferView: some View {
        TrialOfferContent()
    }
}

struct TrialOfferContent: View {
    @EnvironmentObject var model: OnboardingModel
    @State private var bellRotation: Double = 0
    @State private var isAnimating: Bool = true

    var body: some View {
        StepLayout(
            title: "Try Noiseless free for 3 days.",
            subtitle: "We'll send you a reminder before your free trial ends",
            showProgressBar: false
        ) {
            VStack {
                Spacer()

                // Notification Visual
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.zinc800)
                                .frame(width: 40, height: 40)

                            Image("bell_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 26, height: 26)
                                .rotationEffect(.degrees(bellRotation), anchor: .top)
                        }
                        .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Noiseless")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("now")
                                    .font(.system(size: 12))
                                    .foregroundColor(.zinc500)
                            }

                            Text("Your 3-day trial is ending soon.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.zinc200)

                            Text("We'll remind you 24h before you're charged so you have full control.")
                                .font(.system(size: 12))
                                .foregroundColor(.zinc400)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.zinc900.opacity(0.35))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.zinc800.opacity(0.35), lineWidth: 1)
                )
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.4),
                                    Color.purple.opacity(0.3),
                                    Color.blue.opacity(0.15),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 180
                            )
                        )
                        .blur(radius: 50)
                        .scaleEffect(x: 1.3, y: 1.0)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 4)
                
                Spacer()
                
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image("shield_check_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)

                        Text("No Payment Due Now")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.zinc300)
                    }

                    PrimaryButton(title: "Continue for FREE", enableHaptics: false, enablePressAnimation: true) {
                        model.nextStep()
                    }

                    Text("Just 46,99 US$ per year (3,91 US$/mo)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.zinc500)
                }
                .padding(.bottom, 1)
            }
            .onAppear {
                startPeriodicSwing()
            }
            .onDisappear {
                isAnimating = false
            }
        }
    }

    private func startPeriodicSwing() {
        guard isAnimating else { return }

        // Swing right
        withAnimation(.easeInOut(duration: 0.30)) {
            bellRotation = -8
        }

        // Swing sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            guard self.isAnimating else { return }
            withAnimation(.easeInOut(duration: 0.30)) {
                self.bellRotation = 8
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
            guard self.isAnimating else { return }
            withAnimation(.easeInOut(duration: 0.30)) {
                self.bellRotation = -8
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.90) {
            guard self.isAnimating else { return }
            withAnimation(.easeInOut(duration: 0.30)) {
                self.bellRotation = 8
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.20) {
            guard self.isAnimating else { return }
            withAnimation(.easeInOut(duration: 0.30)) {
                self.bellRotation = -8
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.50) {
            guard self.isAnimating else { return }
            withAnimation(.easeInOut(duration: 0.30)) {
                self.bellRotation = 8
            }
        }

        // Final return to center
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.80) {
            guard self.isAnimating else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                self.bellRotation = 0
            }

            // Wait for a pause, then swing again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.startPeriodicSwing()
            }
        }
    }
}

private struct InsightsPreviewContent: View {
    @EnvironmentObject var model: OnboardingModel
    @EnvironmentObject var authController: AuthController
    @State private var showEmailSignIn = false

    var body: some View {
        StepLayout(title: "Save Your Progress", centerContent: true) {
            VStack(spacing: 0) {
                Spacer()

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
        }
        .onChange(of: authController.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                showEmailSignIn = false
                model.nextStep()
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInSheet()
                .environmentObject(authController)
        }
    }
}

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
        // Check if auth state changed via the deep link handler
        // The deep link handler in NoiselessApp will set isAuthenticated to true
        // when the user clicks the magic link
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

