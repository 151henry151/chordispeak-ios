import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Welcome Page
                OnboardingPageView(
                    imageName: "music.note.list",
                    title: "Welcome to ChordiSpeak",
                    description: "Transform your music with AI-powered chord detection and vocal synthesis",
                    showButton: false
                )
                .tag(0)
                
                // Feature 1: Chord Detection
                OnboardingPageView(
                    imageName: "waveform.badge.magnifyingglass",
                    title: "Advanced Chord Detection",
                    description: "Our AI analyzes your audio files to accurately detect chord progressions in real-time",
                    showButton: false
                )
                .tag(1)
                
                // Feature 2: Vocal Synthesis
                OnboardingPageView(
                    imageName: "mic.circle",
                    title: "Natural Vocal Synthesis",
                    description: "Generate realistic vocals that sing your detected chords with customizable voices",
                    showButton: false
                )
                .tag(2)
                
                // Feature 3: Privacy
                OnboardingPageView(
                    imageName: "lock.shield",
                    title: "Your Privacy Matters",
                    description: "Audio files are processed securely and automatically deleted after 24 hours. We never store your personal data.",
                    showButton: false
                )
                .tag(3)
                
                // Get Started
                OnboardingFinalView {
                    completeOnboarding()
                }
                .tag(4)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            // Skip Button
            if currentPage < 4 {
                HStack {
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(.secondary)
                    .padding()
                    
                    Spacer()
                    
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(.blue)
                    .padding()
                }
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let showButton: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .padding()
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            Spacer()
        }
    }
}

struct OnboardingFinalView: View {
    let onComplete: () -> Void
    @State private var agreedToTerms = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
                .padding()
            
            VStack(spacing: 16) {
                Text("Ready to Get Started!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Please review and accept our terms to continue")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            // Terms Agreement
            VStack(spacing: 20) {
                Toggle(isOn: $agreedToTerms) {
                    HStack {
                        Text("I agree to the ")
                        Button("Privacy Policy") {
                            showingPrivacyPolicy = true
                        }
                        .foregroundColor(.blue)
                        Text(" and ")
                        Button("Terms of Service") {
                            showingTermsOfService = true
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.horizontal)
                
                Button(action: onComplete) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(agreedToTerms ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!agreedToTerms)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
    }
}

// Custom Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .blue : .secondary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            configuration.label
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}