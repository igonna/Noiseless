//
//  ProfileDetailsView.swift
//  Noiseless
//
//  Profile details view showing all collected onboarding data
//

import SwiftUI

struct ProfileDetailsView: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) var dismiss
    @State private var userData: UserData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showExportSheet = false
    @State private var exportedJSON: String = ""
    @State private var isExportingJSON = false

    var body: some View {
        ZStack {
            Color(hex: "#09090A")
                .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if let data = userData {
                profileContent(data: data)
            } else {
                noDataView
            }
        }
        .navigationTitle("Your Profile")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showExportSheet) {
            exportJSONSheet
        }
        .onAppear {
            loadUserData()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)

            Text("Loading your profile...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Could not load profile")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: loadUserData) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
    }

    // MARK: - No Data View

    private var noDataView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No profile data found")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text("Complete the onboarding to create your profile")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Profile Content

    private func profileContent(data: UserData) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                profileHeader

                // Data Sections
                VStack(spacing: 16) {
                    if !data.identity.isEmpty {
                        ProfileSection(title: "Identity", icon: "person.fill") {
                            DataRow(label: "Role", value: data.identity)
                            if !data.identityDetail.isEmpty {
                                DataRow(label: "Details", value: data.identityDetail)
                            }
                        }
                    }

                    if !data.location.isEmpty {
                        ProfileSection(title: "Location", icon: "location.fill") {
                            DataRow(label: "Location", value: data.location)
                        }
                    }

                    if !data.skills.isEmpty {
                        ProfileSection(title: "Skills", icon: "star.fill") {
                            TagsView(items: data.skills)
                        }
                    }

                    if !data.traits.isEmpty {
                        ProfileSection(title: "Traits", icon: "sparkles") {
                            TagsView(items: data.traits)
                        }
                    }

                    if !data.vision.isEmpty || !data.visionDetail.isEmpty {
                        ProfileSection(title: "Vision", icon: "eye.fill") {
                            if !data.vision.isEmpty {
                                TagsView(items: data.vision)
                            }
                            if !data.visionDetail.isEmpty {
                                DataRow(label: "Details", value: data.visionDetail)
                            }
                        }
                    }

                    if !data.values.isEmpty {
                        ProfileSection(title: "Values", icon: "heart.fill") {
                            TagsView(items: data.values)
                        }
                    }

                    if !data.constraints.isEmpty || !data.constraintsDetail.isEmpty {
                        ProfileSection(title: "Constraints", icon: "shield.fill") {
                            if !data.constraints.isEmpty {
                                TagsView(items: data.constraints)
                            }
                            if !data.constraintsDetail.isEmpty {
                                DataRow(label: "Details", value: data.constraintsDetail)
                            }
                        }
                    }

                    if !data.timeBudget.isEmpty {
                        ProfileSection(title: "Time Budget", icon: "clock.fill") {
                            DataRow(label: "Daily Time", value: data.timeBudget)
                        }
                    }

                    // Export Button
                    Button(action: { exportJSON() }) {
                        HStack {
                            if isExportingJSON {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Exporting...")
                                    .font(.system(size: 16, weight: .semibold))
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export as JSON")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(isExportingJSON)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.white)
                )

            Text("Your Profile")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text("All your onboarding data")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, 30)
    }

    // MARK: - Export Sheet

    private var exportJSONSheet: some View {
        NavigationView {
            ZStack {
                Color(hex: "#09090A")
                    .ignoresSafeArea()

                ScrollView {
                    Text(exportedJSON)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .navigationTitle("JSON Export")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showExportSheet = false
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: copyToClipboard) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func loadUserData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                print("📡 Loading profile from backend...")
                let data = try await UserDataManager.shared.fetchUserDataFromBackend(authController: authController)

                await MainActor.run {
                    userData = data
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func exportJSON() {
        isExportingJSON = true

        Task {
            do {
                print("📡 Fetching profile from backend for export...")
                let data = try await UserDataManager.shared.fetchUserDataFromBackend(authController: authController)

                // Encode to JSON
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let jsonData = try encoder.encode(data)

                if let json = String(data: jsonData, encoding: .utf8) {
                    await MainActor.run {
                        exportedJSON = json
                        showExportSheet = true
                        isExportingJSON = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to export JSON: \(error.localizedDescription)"
                    isExportingJSON = false
                }
            }
        }
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = exportedJSON
    }
}

// MARK: - Supporting Views

struct ProfileSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
}

struct DataRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TagsView: View {
    let items: [String]

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProfileDetailsView()
    }
}
