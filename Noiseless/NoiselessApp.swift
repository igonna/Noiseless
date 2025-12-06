//
//  NoiselessApp.swift
//  Noiseless
//
//  Created by c on 24.11.25.
//

import SwiftUI
import GoogleSignIn

@main
struct NoiselessApp: App {
    @StateObject private var authController = AuthController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(authController)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
