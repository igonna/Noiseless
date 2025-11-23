import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Text("Profile Details")
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 24))
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
