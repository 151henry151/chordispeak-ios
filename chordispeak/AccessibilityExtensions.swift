import SwiftUI

// MARK: - Accessibility Extensions

extension View {
    /// Adds accessibility label and hint for better VoiceOver support
    func accessibilityElement(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Makes the view accessible as a button with custom label
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(label: label, hint: hint, traits: .isButton)
    }
    
    /// Adds accessibility announcements for dynamic content
    func accessibilityAnnouncement(_ text: String, delay: Double = 0.1) -> some View {
        self.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                UIAccessibility.post(notification: .announcement, argument: text)
            }
        }
    }
    
    /// Groups views for better VoiceOver navigation
    func accessibilityGroup(label: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }
}

// MARK: - Chord Accessibility

extension Chord {
    var accessibilityLabel: String {
        let duration = endTime - startTime
        let durationText = String(format: "%.1f seconds", duration)
        let confidenceText = "\(Int(confidence * 100))% confidence"
        
        return "\(chord) chord, \(durationText), \(confidenceText)"
    }
    
    var accessibilityHint: String {
        "Double tap to hear this chord"
    }
}

// MARK: - Processing Step Accessibility

extension ProcessingStep {
    var accessibilityLabel: String {
        switch self {
        case .uploaded:
            return "File uploaded successfully"
        case .audioPreparation:
            return "Preparing audio for processing"
        case .vocalSeparation:
            return "Separating vocals from instrumental"
        case .voiceSampleExtraction:
            return "Extracting voice characteristics"
        case .chordDetection:
            return "Detecting chord progressions"
        case .ttsSynthesis:
            return "Synthesizing vocal track"
        case .audioMixing:
            return "Mixing final audio"
        case .completed:
            return "Processing completed"
        }
    }
}

// MARK: - Task Status Accessibility

extension TaskStatus {
    var accessibilityLabel: String {
        var components = [String]()
        
        // Status
        components.append("\(status.capitalized) status")
        
        // Current step
        components.append("Current step: \(step)")
        
        // Progress
        if let progress = progress {
            components.append("\(progress)% complete")
        }
        
        // Error
        if let error = error {
            components.append("Error: \(error)")
        }
        
        return components.joined(separator: ", ")
    }
}

// MARK: - Connection Status Accessibility

struct ConnectionStatusAccessibility {
    static func label(isConnected: Bool, serverVersion: String?) -> String {
        if isConnected {
            var label = "Connected to server"
            if let version = serverVersion {
                label += ", version \(version)"
            }
            return label
        } else {
            return "Server disconnected. Please check your internet connection."
        }
    }
}

// MARK: - Audio File Accessibility

struct AudioFileAccessibility {
    static func label(filename: String, size: Int64?) -> String {
        var label = "Selected file: \(filename)"
        
        if let size = size {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            let sizeString = formatter.string(fromByteCount: size)
            label += ", size: \(sizeString)"
        }
        
        return label
    }
    
    static func uploadHint(isConnected: Bool) -> String {
        if isConnected {
            return "Double tap to start processing this audio file"
        } else {
            return "Cannot process. Server connection required."
        }
    }
}

// MARK: - VoiceOver Utility

struct VoiceOverUtility {
    /// Announces text with VoiceOver
    static func announce(_ text: String, delay: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }
    
    /// Announces screen change
    static func announceScreenChange(_ text: String) {
        UIAccessibility.post(notification: .screenChanged, argument: text)
    }
    
    /// Checks if VoiceOver is running
    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
    
    /// Gets preferred content size category
    static var preferredContentSizeCategory: ContentSizeCategory {
        ContentSizeCategory(UIApplication.shared.preferredContentSizeCategory)
    }
    
    /// Checks if user prefers reduced motion
    static var prefersReducedMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
}

// MARK: - Dynamic Type Support

extension Font {
    /// Returns a scaled font based on the user's preferred text size
    static func scaledFont(_ style: Font.TextStyle, design: Font.Design = .default) -> Font {
        return Font.system(style, design: design)
    }
    
    /// Custom scaled font with maximum size limit
    static func scaledFont(_ style: Font.TextStyle, maxSize: CGFloat) -> Font {
        let fontSize = UIFontMetrics(forTextStyle: UIFont.TextStyle(style)).scaledValue(for: maxSize)
        return Font.system(size: min(fontSize, maxSize))
    }
}

// UIFont.TextStyle bridge
extension UIFont.TextStyle {
    init(_ swiftUIStyle: Font.TextStyle) {
        switch swiftUIStyle {
        case .largeTitle: self = .largeTitle
        case .title: self = .title1
        case .title2: self = .title2
        case .title3: self = .title3
        case .headline: self = .headline
        case .subheadline: self = .subheadline
        case .body: self = .body
        case .callout: self = .callout
        case .footnote: self = .footnote
        case .caption: self = .caption1
        case .caption2: self = .caption2
        default: self = .body
        }
    }
}