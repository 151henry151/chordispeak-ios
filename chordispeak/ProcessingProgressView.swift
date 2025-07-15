import SwiftUI

struct ProcessingProgressView: View {
    let taskStatus: TaskStatus
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progressValue)
                
                VStack {
                    Text("\(Int(progressValue * 100))%")
                        .font(.title2)
                        .fontWeight(Font.Weight.bold)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Current Step
            VStack(spacing: 8) {
                Text("Current Step")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(taskStatus.step)
                    .font(.title3)
                    .fontWeight(Font.Weight.semibold)
                    .multilineTextAlignment(.center)
            }
            
            // Status Badge
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                Text(taskStatus.status.capitalized)
                    .font(.subheadline)
                    .fontWeight(Font.Weight.medium)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.1))
            .cornerRadius(20)
        }
        .padding()
    }
    
    private var progressValue: Double {
        guard let progress = taskStatus.progress else {
            // Estimate progress based on step
            return estimatedProgress
        }
        return Double(progress) / 100.0
    }
    
    private var estimatedProgress: Double {
        let step = taskStatus.step.lowercased()
        
        if step.contains("uploaded") { return 0.05 }
        if step.contains("audio preparation") { return 0.10 }
        if step.contains("vocal separation") { return 0.25 }
        if step.contains("voice sample") { return 0.30 }
        if step.contains("chord detection") { return 0.65 }
        if step.contains("tts synthesis") { return 0.85 }
        if step.contains("audio mixing") { return 0.95 }
        if step.contains("completed") { return 1.0 }
        
        return 0.0
    }
    
    private var statusColor: Color {
        switch taskStatus.status {
        case "queued": return .orange
        case "processing": return .blue
        case "completed": return .green
        case "failed": return .red
        case "cancelled": return .gray
        default: return .gray
        }
    }
}

struct ProcessingStepsView: View {
    let currentStep: String
    
    private let steps = [
        "Uploaded",
        "Audio Preparation", 
        "Vocal Separation",
        "Voice Sample Extraction",
        "Chord Detection",
        "TTS Synthesis",
        "Audio Mixing",
        "Completed"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(steps, id: \.self) { step in
                HStack(spacing: 12) {
                    // Step indicator
                    ZStack {
                        Circle()
                            .fill(stepColor(for: step))
                            .frame(width: 24, height: 24)
                        
                        if isStepCompleted(step) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(Color.white)
                        } else if isCurrentStep(step) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    // Step name
                    Text(step)
                        .font(.subheadline)
                        .foregroundColor(isCurrentStep(step) ? .primary : .secondary)
                        .fontWeight(isCurrentStep(step) ? Font.Weight.semibold : Font.Weight.regular)
                    
                    Spacer()
                }
            }
        }
        .padding()
    }
    
    private func stepColor(for step: String) -> Color {
        if isStepCompleted(step) {
            return .green
        } else if isCurrentStep(step) {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func isStepCompleted(_ step: String) -> Bool {
        let currentIndex = steps.firstIndex(of: currentStep) ?? 0
        let stepIndex = steps.firstIndex(of: step) ?? 0
        return stepIndex < currentIndex
    }
    
    private func isCurrentStep(_ step: String) -> Bool {
        return step == currentStep
    }
}

struct ProcessingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            ProcessingProgressView(
                taskStatus: TaskStatus(
                    taskId: "test",
                    status: "processing",
                    step: "Chord Detection",
                    filename: "test.mp3",
                    progress: 45,
                    outputFile: nil,
                    error: nil
                )
            )
            
            ProcessingStepsView(currentStep: "Chord Detection")
        }
    }
} 