import AuthenticationServices
import Combine
import CryptoKit
import Foundation
import SwiftUI
import Supabase

@MainActor
final class AuthController: NSObject, ObservableObject {
    enum SignInProvider {
        case apple
        case email

        var buttonLabel: String {
            switch self {
            case .apple: return "Apple"
            case .email: return "Email"
            }
        }
    }

    @Published private(set) var isAuthenticating: Bool = false
    @Published private(set) var activeProvider: SignInProvider?
    @Published private(set) var lastErrorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var userInfo: UserInfo?

    struct UserInfo {
        let userId: String
        let email: String?
        let fullName: String?
    }

    let supabase: SupabaseClient
    private var currentNonce: String?

    override init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: "https://auenzufveqkodwuarkbi.supabase.co")!,
            supabaseKey: "sb_publishable_4KVLWjJDUKN0vbbLOfE6QA_mm95zc5y"
        )
        super.init()
    }

    func getAccessToken() async -> String? {
        do {
            let session = try await supabase.auth.session
            return session.accessToken
        } catch {
            print("Failed to get access token: \(error)")
            return nil
        }
    }

    func signIn(with provider: SignInProvider) {
        guard !isAuthenticating else { return }

        lastErrorMessage = nil
        activeProvider = provider
        isAuthenticating = true

        Task {
            switch provider {
            case .apple:
                await signInWithApple()
            case .email:
                // Email sign-in will be handled separately with email/password
                break
            }
        }
    }

    func signInWithMagicLink(email: String) async -> Bool {
        guard !isAuthenticating else { return false }

        lastErrorMessage = nil
        activeProvider = .email
        isAuthenticating = true

        do {
            try await supabase.auth.signInWithOTP(
                email: email,
                redirectTo: URL(string: "noiseless://auth-callback")
            )

            // Magic link sent successfully
            resetState(errorMessage: nil, preserveAuthFlag: false)
            return true
        } catch {
            resetState(errorMessage: error.localizedDescription)
            return false
        }
    }

    private func signInWithApple() async {
        currentNonce = randomNonceString()

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(currentNonce!)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func resetState(errorMessage: String?, preserveAuthFlag: Bool = false) {
        if !preserveAuthFlag {
            isAuthenticated = false
        }
        lastErrorMessage = errorMessage
        isAuthenticating = false
        activeProvider = nil
    }
}

extension AuthController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            resetState(errorMessage: "Unable to get Apple ID token")
            return
        }

        Task { @MainActor in
            do {
                let session = try await supabase.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: identityToken,
                        nonce: nonce
                    )
                )

                var fullName: String?
                if let nameComponents = appleIDCredential.fullName {
                    let formatter = PersonNameComponentsFormatter()
                    fullName = formatter.string(from: nameComponents)
                }

                let userInfo = UserInfo(
                    userId: session.user.id.uuidString,
                    email: session.user.email ?? appleIDCredential.email,
                    fullName: fullName
                )

                self.userInfo = userInfo
                self.isAuthenticated = true
                self.resetState(errorMessage: nil, preserveAuthFlag: true)
            } catch {
                self.resetState(errorMessage: error.localizedDescription)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError {
            if authError.code == .canceled {
                resetState(errorMessage: "Sign in was canceled.")
            } else {
                resetState(errorMessage: authError.localizedDescription)
            }
        } else {
            resetState(errorMessage: error.localizedDescription)
        }
    }
}

extension AuthController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
