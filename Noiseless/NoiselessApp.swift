//
//  NoiselessApp.swift
//  Noiseless
//
//  Created by c on 24.11.25.
//

import SwiftUI
import Supabase

@main
struct NoiselessApp: App {
    @StateObject private var authController = AuthController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(authController)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        // Handle magic link callback
        Task {
            do {
                let session = try await authController.supabase.auth.session(from: url)

                let userInfo = AuthController.UserInfo(
                    userId: session.user.id.uuidString,
                    email: session.user.email,
                    fullName: session.user.userMetadata["full_name"] as? String
                )

                await MainActor.run {
                    authController.userInfo = userInfo
                    authController.isAuthenticated = true
                }
            } catch {
                print("Deep link auth error: \(error.localizedDescription)")
            }
        }
    }
}
