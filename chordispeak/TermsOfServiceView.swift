import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Text("Effective Date: January 20, 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Agreement
                    SectionView(
                        title: "1. Agreement to Terms",
                        content: """
                        By accessing and using ChordiSpeak ("App"), you agree to be bound by these Terms of Service ("Terms"). If you disagree with any part of these terms, you do not have permission to access the App.
                        """
                    )
                    
                    // Use License
                    SectionView(
                        title: "2. Use License",
                        content: """
                        Permission is granted to temporarily download one copy of ChordiSpeak for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:
                        
                        • Modify or copy the materials
                        • Use the materials for any commercial purpose or for any public display
                        • Attempt to reverse engineer any software contained in ChordiSpeak
                        • Remove any copyright or other proprietary notations from the materials
                        
                        This license shall automatically terminate if you violate any of these restrictions and may be terminated by ChordiSpeak at any time.
                        """
                    )
                    
                    // Service Description
                    SectionView(
                        title: "3. Service Description",
                        content: """
                        ChordiSpeak provides audio processing services including:
                        
                        • Chord detection from audio files
                        • Vocal synthesis based on detected chords
                        • Audio mixing and processing
                        
                        The service requires an internet connection for processing. We do not guarantee 100% accuracy in chord detection or vocal synthesis quality.
                        """
                    )
                    
                    // User Content
                    SectionView(
                        title: "4. User Content",
                        content: """
                        By uploading audio files to ChordiSpeak, you:
                        
                        • Warrant that you own or have the necessary licenses, rights, consents, and permissions to use and authorize us to process the audio
                        • Grant us a temporary, non-exclusive license to process your audio files solely for the purpose of providing our services
                        • Acknowledge that we automatically delete uploaded files within 24 hours of processing
                        • Agree not to upload copyrighted material without proper authorization
                        """
                    )
                    
                    // Prohibited Uses
                    SectionView(
                        title: "5. Prohibited Uses",
                        content: """
                        You may not use ChordiSpeak:
                        
                        • For any unlawful purpose or to solicit others to perform unlawful acts
                        • To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances
                        • To infringe upon or violate our intellectual property rights or the intellectual property rights of others
                        • To submit false or misleading information
                        • To upload or transmit viruses or any other type of malicious code
                        • To interfere with or circumvent the security features of the Service
                        """
                    )
                    
                    // Intellectual Property
                    SectionView(
                        title: "6. Intellectual Property Rights",
                        content: """
                        The Service and its original content, features, and functionality are and will remain the exclusive property of ChordiSpeak and its licensors. The Service is protected by copyright, trademark, and other laws. Our trademarks and trade dress may not be used in connection with any product or service without our prior written consent.
                        """
                    )
                    
                    // Disclaimer
                    SectionView(
                        title: "7. Disclaimer",
                        content: """
                        THE INFORMATION ON THIS APP IS PROVIDED ON AN "AS IS" BASIS. TO THE FULLEST EXTENT PERMITTED BY LAW, THIS COMPANY:
                        
                        • EXCLUDES ALL REPRESENTATIONS AND WARRANTIES RELATING TO THIS APP AND ITS CONTENTS
                        • EXCLUDES ALL LIABILITY FOR DAMAGES ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF THIS APP
                        
                        This includes, without limitation, direct loss, loss of business or profits, and any indirect, incidental, special, or consequential loss.
                        """
                    )
                    
                    // Limitations
                    SectionView(
                        title: "8. Limitations",
                        content: """
                        In no event shall ChordiSpeak or its suppliers be liable for any damages arising out of the use or inability to use the materials on ChordiSpeak, even if ChordiSpeak or an authorized representative has been notified orally or in writing of the possibility of such damage.
                        """
                    )
                    
                    // Privacy
                    SectionView(
                        title: "9. Privacy",
                        content: """
                        Your use of ChordiSpeak is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs the App and informs users of our data collection practices.
                        """
                    )
                    
                    // Governing Law
                    SectionView(
                        title: "10. Governing Law",
                        content: """
                        These Terms shall be governed and construed in accordance with the laws of the United States, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.
                        """
                    )
                    
                    // Changes to Terms
                    SectionView(
                        title: "11. Changes to Terms",
                        content: """
                        We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect.
                        """
                    )
                    
                    // Contact Information
                    SectionView(
                        title: "12. Contact Information",
                        content: """
                        If you have any questions about these Terms, please contact us at:
                        
                        **ChordiSpeak**
                        Email: support@chordispeak.app
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

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
    }
}