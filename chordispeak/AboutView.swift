import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // App Icon and Name
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                            )
                        
                        Text("ChordiSpeak")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("AI Chord Vocal Generator")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Version \(getAppVersion())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About ChordiSpeak")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("ChordiSpeak is an innovative iOS application that uses advanced AI technology to detect chords from your audio files and generate vocal renditions of those chords. Perfect for musicians, music students, and anyone interested in understanding the harmonic structure of their favorite songs.")
                            .font(.body)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Features")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        FeatureRow(icon: "waveform", title: "Advanced Chord Detection", description: "State-of-the-art AI models for accurate chord recognition")
                        
                        FeatureRow(icon: "mic.fill", title: "Vocal Synthesis", description: "Generate natural-sounding vocals that sing detected chords")
                        
                        FeatureRow(icon: "music.note", title: "Multiple Audio Formats", description: "Support for MP3, WAV, FLAC, and M4A files")
                        
                        FeatureRow(icon: "lock.shield.fill", title: "Privacy Focused", description: "Your audio files are processed securely and deleted after 24 hours")
                    }
                    .padding(.horizontal)
                    
                    // Technology
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Technology")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("ChordiSpeak leverages cutting-edge machine learning models including:")
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TechRow(name: "PyTorch", description: "Deep learning framework")
                            TechRow(name: "Transformer Models", description: "Advanced neural networks")
                            TechRow(name: "TTS Technology", description: "Text-to-speech synthesis")
                            TechRow(name: "SwiftUI", description: "Modern iOS interface")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Credits")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            CreditRow(role: "Development", name: "Romp Family Enterprises")
                            CreditRow(role: "Design", name: "ChordiSpeak Team")
                            CreditRow(role: "Backend Infrastructure", name: "Google Cloud Platform")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Links
                    VStack(spacing: 16) {
                        Link(destination: URL(string: "https://chordispeak.app")!) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Visit Our Website")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Link(destination: URL(string: "https://github.com/chordispeak")!) {
                            HStack {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                Text("Open Source Components")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Copyright
                    Text("© 2025 Romp Family Enterprises. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
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
    
    private func getAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct TechRow: View {
    let name: String
    let description: String
    
    var body: some View {
        HStack {
            Text("• \(name)")
                .fontWeight(.medium)
            Text("- \(description)")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct CreditRow: View {
    let role: String
    let name: String
    
    var body: some View {
        HStack {
            Text(role)
                .foregroundColor(.secondary)
                .frame(width: 150, alignment: .leading)
            Text(name)
                .fontWeight(.medium)
            Spacer()
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}