import AuthenticationServices
import Combine
import CryptoKit
import Foundation
import GoogleSignIn
import SwiftUI
import UIKit

@MainActor
final class AuthController: NSObject, ObservableObject {
    enum SignInProvider {
        case apple
        case google
    }

    @Published private(set) var isAuthenticating: Bool = false
    @Published private(set) var activeProvider: SignInProvider?
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var authToken: String?

    private var authSession: ASWebAuthenticationSession?
    private var currentNonce: String?

    // Configure your backend API endpoint
    private let backendURL = "http://192.168.18.184:6469"

    func signIn(with provider: SignInProvider) {
        guard !isAuthenticating else { return }

        lastErrorMessage = nil
        activeProvider = provider
        isAuthenticating = true

        switch provider {
        case .apple:
            signInWithApple()
        case .google:
            signInWithGoogle()
        }
    }

    // MARK: - Native Apple Sign In

    private func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // MARK: - Native Google Sign In

    private func signInWithGoogle() {
        guard let presentingViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
            resetState(errorMessage: "Unable to present Google Sign-In")
            return
        }

        let config = GIDConfiguration(clientID: GoogleOAuthConfig.clientID)

        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: []
        ) { [weak self] result, error in
            guard let self else { return }

            Task { @MainActor in
                if let error {
                    self.resetState(errorMessage: error.localizedDescription)
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self.resetState(errorMessage: "Failed to get Google ID token")
                    return
                }

                do {
                    try await self.authenticateWithBackend(
                        provider: "google",
                        idToken: idToken,
                        nonce: nil
                    )
                    self.resetState(errorMessage: nil, preserveAuthFlag: true)
                } catch {
                    self.resetState(errorMessage: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Backend Authentication

    private func authenticateWithBackend(provider: String, idToken: String, nonce: String?) async throws {
        var request = URLRequest(url: URL(string: "\(backendURL)/v1/auth/sign-in")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "provider": provider,
            "idToken": idToken,
            "nonce": nonce as Any
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
        }

        // Parse response
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let token = json?["token"] as? String else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
        }

        authToken = token
        isAuthenticated = true
    }

    private func resetState(errorMessage: String?, preserveAuthFlag: Bool = false) {
        if !preserveAuthFlag {
            isAuthenticated = false
        }
        lastErrorMessage = errorMessage
        isAuthenticating = false
        activeProvider = nil
        authSession = nil
        currentNonce = nil
    }

    // MARK: - Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
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
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            resetState(errorMessage: "Failed to get Apple ID credentials")
            return
        }

        Task {
            do {
                try await authenticateWithBackend(
                    provider: "apple",
                    idToken: idTokenString,
                    nonce: nonce
                )
                resetState(errorMessage: nil, preserveAuthFlag: true)
            } catch {
                resetState(errorMessage: error.localizedDescription)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError,
           authError.code == .canceled {
            resetState(errorMessage: "Sign in was canceled.")
        } else {
            resetState(errorMessage: error.localizedDescription)
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

// MARK: - Google OAuth Configuration

enum GoogleOAuthConfig {
    static let clientID = "457939736670-3tkd737l4kvgbmmem9stvdrlfflmcg9s.apps.googleusercontent.com"
}
