import SwiftUI
import WebKit

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Text("Effective Date: January 20, 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Introduction
                    SectionView(
                        title: "Introduction",
                        content: """
                        ChordiSpeak ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our iOS application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.
                        """
                    )
                    
                    // Information We Collect
                    SectionView(
                        title: "Information We Collect",
                        content: """
                        We collect information you provide directly to us, such as:
                        
                        • **Audio Files**: When you upload audio files for processing, we temporarily store these files only for the duration of processing.
                        • **Usage Data**: We collect anonymous usage statistics to improve our service.
                        • **Device Information**: We may collect device identifiers, iOS version, and app version for troubleshooting purposes.
                        
                        We do NOT collect:
                        • Personal identification information (name, email, phone number)
                        • Location data
                        • Contact information
                        • Photos or videos (except audio files you explicitly upload)
                        """
                    )
                    
                    // How We Use Your Information
                    SectionView(
                        title: "How We Use Your Information",
                        content: """
                        We use the information we collect to:
                        
                        • Process your audio files for chord detection and vocal synthesis
                        • Improve our machine learning models and service quality
                        • Provide technical support and respond to user inquiries
                        • Monitor and analyze usage patterns to improve the app
                        • Ensure the security and proper functioning of our service
                        """
                    )
                    
                    // Data Storage and Security
                    SectionView(
                        title: "Data Storage and Security",
                        content: """
                        • **Temporary Storage**: Audio files are stored temporarily on our secure servers during processing and are automatically deleted within 24 hours.
                        • **Processed Results**: Chord detection results and synthesized audio are stored locally on your device.
                        • **Security Measures**: We use industry-standard SSL/TLS encryption for all data transfers.
                        • **No Cloud Backup**: We do not store your audio files or processing results in the cloud unless you explicitly choose to save them to iCloud.
                        """
                    )
                    
                    // Third-Party Services
                    SectionView(
                        title: "Third-Party Services",
                        content: """
                        Our app uses the following third-party services:
                        
                        • **Google Cloud Run**: For hosting our processing backend
                        • **PyTorch**: For machine learning model execution
                        • **Apple Services**: Standard iOS frameworks and services
                        
                        These services have their own privacy policies, and we encourage you to review them.
                        """
                    )
                    
                    // Your Rights
                    SectionView(
                        title: "Your Rights",
                        content: """
                        You have the right to:
                        
                        • **Access**: Request access to the personal data we process about you
                        • **Deletion**: Request deletion of your data from our servers
                        • **Opt-out**: Disable anonymous usage analytics in the app settings
                        • **Data Portability**: Export your chord detection results
                        
                        To exercise these rights, please contact us at privacy@chordispeak.app
                        """
                    )
                    
                    // Children's Privacy
                    SectionView(
                        title: "Children's Privacy",
                        content: """
                        Our service is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.
                        """
                    )
                    
                    // Changes to This Policy
                    SectionView(
                        title: "Changes to This Privacy Policy",
                        content: """
                        We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Effective Date" at the top.
                        """
                    )
                    
                    // Contact Us
                    SectionView(
                        title: "Contact Us",
                        content: """
                        If you have questions or comments about this Privacy Policy, please contact us at:
                        
                        **ChordiSpeak**
                        Email: privacy@chordispeak.app
                        Website: https://chordispeak.app
                        """
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(.init(content)) // This allows for markdown formatting
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}