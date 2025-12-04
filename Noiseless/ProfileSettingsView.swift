import SwiftUI

// Shared background color constant
private let appBackgroundColor = Color(hex: "09090A")

struct ProfileSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
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
                        Button("Log Out", role: .destructive) {
                            // Action
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(appBackgroundColor)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
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
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
    }
}
