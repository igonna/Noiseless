import AuthenticationServices
import Combine
import Foundation
import Supabase
import SwiftUI
import UIKit

@MainActor
final class SupabaseAuthController: NSObject, ObservableObject {
    enum SignInProvider {
        case apple
        case google

        var buttonLabel: String {
            switch self {
            case .apple: return "Apple"
            case .google: return "Google"
            }
        }
    }

    @Published private(set) var isAuthenticating: Bool = false
    @Published private(set) var activeProvider: SignInProvider?
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var isAuthenticated: Bool = false

    let client: SupabaseClient

    private var authSession: ASWebAuthenticationSession?

    override init() {
        client = SupabaseClient(
            supabaseURL: SupabaseCredentials.projectURL,
            supabaseKey: SupabaseCredentials.publishableKey
        )
        super.init()
    }

    func signIn(with provider: SignInProvider) {
        guard !isAuthenticating else { return }

        lastErrorMessage = nil
        activeProvider = provider
        isAuthenticating = true

        Task {
            do {
                let authURL = try await oauthURL(for: provider)
                presentSession(for: authURL)
            } catch {
                resetState(errorMessage: error.localizedDescription)
            }
        }
    }

    func handleDeeplink(_ url: URL) {
        Task {
            do {
                _ = try await client.auth.session(from: url)
                isAuthenticated = true
                resetState(errorMessage: nil, preserveAuthFlag: true)
            } catch {
                resetState(errorMessage: error.localizedDescription)
            }
        }
    }

    private func oauthURL(for provider: SignInProvider) async throws -> URL {
        switch provider {
        case .apple:
            return try await client.auth.getOAuthSignInURL(
                provider: .apple,
                redirectTo: SupabaseCredentials.redirectURL
            )
        case .google:
            return try await client.auth.getOAuthSignInURL(
                provider: .google,
                redirectTo: SupabaseCredentials.redirectURL
            )
        }
    }

    private func presentSession(for url: URL) {
        authSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: SupabaseCredentials.callbackScheme
        ) { [weak self] callbackURL, error in
            guard let self else { return }

            Task { @MainActor in
                if let error {
                    self.handleSessionError(error)
                    return
                }

                guard let callbackURL else {
                    self.resetState(errorMessage: "Missing OAuth callback.")
                    return
                }

                do {
                    _ = try await self.client.auth.session(from: callbackURL)
                    self.isAuthenticated = true
                    self.resetState(errorMessage: nil, preserveAuthFlag: true)
                } catch {
                    self.resetState(errorMessage: error.localizedDescription)
                }
            }
        }

        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = true
        _ = authSession?.start()
    }

    private func handleSessionError(_ error: Error) {
        if let webAuthError = error as? ASWebAuthenticationSessionError,
           webAuthError.code == .canceledLogin {
            resetState(errorMessage: "Sign in was canceled.")
        } else {
            resetState(errorMessage: error.localizedDescription)
        }
    }

    private func resetState(errorMessage: String?, preserveAuthFlag: Bool = false) {
        if !preserveAuthFlag {
            isAuthenticated = false
        }
        lastErrorMessage = errorMessage
        isAuthenticating = false
        activeProvider = nil
        authSession = nil
    }
}

extension SupabaseAuthController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

enum SupabaseCredentials {
    static let projectURL: URL = {
        guard let url = URL(string: "http://192.168.18.184:54321") else {
            fatalError("Invalid Supabase URL.")
        }
        return url
    }()

    static let publishableKey: String = "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"

    static let redirectURL: URL = {
        guard let url = URL(string: "noiseless://auth-callback") else {
            fatalError("Invalid redirect URL.")
        }
        return url
    }()

    static let callbackScheme: String = "noiseless"
}
