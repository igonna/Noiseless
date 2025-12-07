import SwiftUI

// Shared background color constant
private let appBackgroundColor = Color(hex: "09090A")

struct ProfileSettingsView: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var showLogoutConfirmation = false
    @State private var isLoggingOut = false

    var body: some View {
        ZStack {
            appBackgroundColor
                .ignoresSafeArea()

            NavigationView {
                List {
                    Section(header: Text("Account")) {
                        NavigationLink(destination: ProfileDetailsView()) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Profile Details")
                            }
                        }
                        Text("Notifications")
                        Text("Privacy")
                    }

                    Section(header: Text("App")) {
                        Text("Appearance")
                        Text("About")
                    }

                    Section {
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            HStack {
                                if isLoggingOut {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Text("Logging out...")
                                        .foregroundColor(.red)
                                } else {
                                    Text("Log Out")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .disabled(isLoggingOut)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(appBackgroundColor)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .alert("Log Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to log out? You'll need to sign in again to access your account.")
        }
    }

    private func handleLogout() {
        isLoggingOut = true

        Task {
            print("🚪 User initiated logout from settings...")
            await authController.signOut()

            await MainActor.run {
                // Clear local user data
                UserDataManager.shared.clearUserData()
                print("🗑️ Cleared local user data")

                // Reset onboarding flag to go back to login screen
                hasCompletedOnboarding = false
                print("🔄 Reset onboarding flag")

                isLoggingOut = false
                dismiss()
                print("✅ Logged out and dismissed settings")
            }
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
    }
}
