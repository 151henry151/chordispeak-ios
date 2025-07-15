import SwiftUI

struct ChordProgressionView: View {
    let chordData: ChordData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chord Progression")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(chordData.chords.enumerated()), id: \.offset) { index, chord in
                        ChordTimelineRow(
                            chord: chord,
                            isFirst: index == 0,
                            isLast: index == chordData.chords.count - 1
                        )
                    }
                }
            }
        }
        .padding()
    }
}

struct ChordTimelineRow: View {
    let chord: Chord
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline connector
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 20)
                }
                
                Circle()
                    .fill(chordColor)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 20)
                }
            }
            
            // Chord info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chord.chord)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(chordColor)
                    
                    Spacer()
                    
                    Text("\(Int(chord.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(timeRangeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var timeRangeText: String {
        let startTime = formatTime(chord.startTime)
        let endTime = formatTime(chord.endTime)
        return "\(startTime) - \(endTime)"
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private var chordColor: Color {
        // Color coding based on chord type
        let chord = self.chord.chord.lowercased()
        
        if chord.contains("maj") || chord.contains("major") {
            return .blue
        } else if chord.contains("min") || chord.contains("minor") || chord.contains("m") {
            return .purple
        } else if chord.contains("7") {
            return .orange
        } else if chord.contains("dim") {
            return .red
        } else if chord.contains("aug") {
            return .green
        } else if chord.contains("sus") {
            return .pink
        } else {
            return .primary
        }
    }
}

struct ChordSummaryView: View {
    let chordData: ChordData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chord Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(chordCounts, id: \.key) { chord, count in
                    VStack(spacing: 4) {
                        Text(chord)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(count) times")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    private var chordCounts: [(key: String, value: Int)] {
        let counts = Dictionary(grouping: chordData.chords, by: { $0.chord })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return Array(counts.prefix(9)) // Show top 9 chords
    }
}

struct ChordProgressionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ChordProgressionView(
                chordData: ChordData(
                    chords: [
                        Chord(chord: "C", startTime: 0.0, endTime: 2.5, confidence: 0.95),
                        Chord(chord: "Am", startTime: 2.5, endTime: 5.0, confidence: 0.87),
                        Chord(chord: "F", startTime: 5.0, endTime: 7.5, confidence: 0.92),
                        Chord(chord: "G", startTime: 7.5, endTime: 10.0, confidence: 0.89)
                    ]
                )
            )
            
            ChordSummaryView(
                chordData: ChordData(
                    chords: [
                        Chord(chord: "C", startTime: 0.0, endTime: 2.5, confidence: 0.95),
                        Chord(chord: "Am", startTime: 2.5, endTime: 5.0, confidence: 0.87),
                        Chord(chord: "F", startTime: 5.0, endTime: 7.5, confidence: 0.92),
                        Chord(chord: "G", startTime: 7.5, endTime: 10.0, confidence: 0.89)
                    ]
                )
            )
        }
    }
} 