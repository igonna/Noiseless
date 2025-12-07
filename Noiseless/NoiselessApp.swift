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
        print("📧 Deep link received: \(url.absoluteString)")
        Task {
            do {
                print("🔗 Processing magic link session...")
                let session = try await authController.supabase.auth.session(from: url)
                print("✅ Magic link session established, user ID: \(session.user.id.uuidString)")

                let userInfo = AuthController.UserInfo(
                    userId: session.user.id.uuidString,
                    email: session.user.email,
                    fullName: session.user.userMetadata["full_name"] as? String
                )

                await MainActor.run {
                    authController.userInfo = userInfo
                    print("🔄 Setting isAuthenticated = true (from magic link)")
                    authController.isAuthenticated = true
                    print("✅ Magic link authentication complete")
                }
            } catch {
                print("❌ Deep link auth error: \(error.localizedDescription)")
            }
        }
    }
}
