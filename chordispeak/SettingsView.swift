import SwiftUI
import MessageUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("analyticsEnabled") private var analyticsEnabled = true
    @AppStorage("autoDeleteFiles") private var autoDeleteFiles = true
    @AppStorage("highQualityProcessing") private var highQualityProcessing = false
    
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingMailComposer = false
    @State private var showingAbout = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                // App Settings Section
                Section(header: Text("App Settings")) {
                    Toggle("Analytics", isOn: $analyticsEnabled)
                        .onChange(of: analyticsEnabled) { _ in
                            // Update analytics settings
                        }
                    
                    Toggle("Auto-Delete Processed Files", isOn: $autoDeleteFiles)
                    
                    Toggle("High Quality Processing", isOn: $highQualityProcessing)
                        .onChange(of: highQualityProcessing) { _ in
                            // Update processing quality
                        }
                }
                
                // Legal Section
                Section(header: Text("Legal")) {
                    Button(action: {
                        showingPrivacyPolicy = true
                    }) {
                        HStack {
                            Label("Privacy Policy", systemImage: "lock.shield")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showingTermsOfService = true
                    }) {
                        HStack {
                            Label("Terms of Service", systemImage: "doc.text")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Support Section
                Section(header: Text("Support")) {
                    Button(action: {
                        if MFMailComposeViewController.canSendMail() {
                            showingMailComposer = true
                        } else {
                            // Open mail app
                            if let url = URL(string: "mailto:support@chordispeak.app") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }) {
                        HStack {
                            Label("Contact Support", systemImage: "envelope")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://chordispeak.app/faq")!) {
                        HStack {
                            Label("FAQ", systemImage: "questionmark.circle")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://chordispeak.app")!) {
                        HStack {
                            Label("Website", systemImage: "globe")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Data Management Section
                Section(header: Text("Data Management")) {
                    Button(action: {
                        clearCache()
                    }) {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Delete All Data", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Label("About ChordiSpeak", systemImage: "info.circle")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(getAppVersion())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(getBuildNumber())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposerView(
                recipients: ["support@chordispeak.app"],
                subject: "ChordiSpeak Support",
                body: generateSupportEmailBody()
            )
        }
        .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will delete all processed audio files and chord data. This action cannot be undone.")
        }
    }
    
    // Helper Functions
    private func clearCache() {
        // Clear temporary files
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                if fileURL.lastPathComponent.hasPrefix("temp_") {
                    try fileManager.removeItem(at: fileURL)
                }
            }
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
    private func deleteAllData() {
        // Delete all user data
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error deleting data: \(error)")
        }
        
        // Clear UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    private func getAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private func getBuildNumber() -> String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    private func generateSupportEmailBody() -> String {
        let device = UIDevice.current
        let appVersion = getAppVersion()
        let buildNumber = getBuildNumber()
        
        return """
        
        
        -----
        Device Information:
        Model: \(device.model)
        iOS Version: \(device.systemVersion)
        App Version: \(appVersion) (\(buildNumber))
        """
    }
}

// Mail Composer View
struct MailComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}