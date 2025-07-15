import Foundation

// MARK: - API Models

struct UploadResponse: Codable {
    let taskId: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
    }
}

struct TaskStatus: Codable {
    let taskId: String?
    let status: String
    let step: String
    let filename: String?
    let progress: Int?
    let outputFile: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status, step, filename, progress
        case outputFile = "output_file"
        case error
    }
}

struct ChordData: Codable {
    let chords: [Chord]
}

struct Chord: Codable {
    let chord: String
    let startTime: Double
    let endTime: Double
    let confidence: Double
    
    enum CodingKeys: String, CodingKey {
        case chord
        case startTime = "start_time"
        case endTime = "end_time"
        case confidence
    }
}

struct HealthResponse: Codable {
    let status: String
    let version: String
    let name: String
    let gpu: GPUInfo
}

struct GPUInfo: Codable {
    let pytorchVersion: String
    let cudaAvailable: Bool
    let cudaDeviceCount: Int
    let cudaDeviceName: String
    let cudaMemoryAllocatedGB: Double
    
    enum CodingKeys: String, CodingKey {
        case pytorchVersion = "pytorch_version"
        case cudaAvailable = "cuda_available"
        case cudaDeviceCount = "cuda_device_count"
        case cudaDeviceName = "cuda_device_name"
        case cudaMemoryAllocatedGB = "cuda_memory_allocated_gb"
    }
}

// MARK: - Task States

enum TaskState: String, CaseIterable {
    case queued = "queued"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .queued: return "Queued"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var isActive: Bool {
        return self == .queued || self == .processing
    }
}

// MARK: - Processing Steps

enum ProcessingStep: String, CaseIterable {
    case uploaded = "Uploaded"
    case audioPreparation = "Audio Preparation"
    case vocalSeparation = "Vocal Separation"
    case voiceSampleExtraction = "Voice Sample Extraction"
    case chordDetection = "Chord Detection"
    case ttsSynthesis = "TTS Synthesis"
    case audioMixing = "Audio Mixing"
    case completed = "Completed"
    
    var displayName: String {
        return rawValue
    }
    
    var progressRange: ClosedRange<Int> {
        switch self {
        case .uploaded: return 0...5
        case .audioPreparation: return 5...10
        case .vocalSeparation: return 10...25
        case .voiceSampleExtraction: return 25...30
        case .chordDetection: return 30...65
        case .ttsSynthesis: return 65...85
        case .audioMixing: return 85...100
        case .completed: return 100...100
        }
    }
} 