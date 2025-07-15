import Foundation
import Combine
import SwiftUI

@MainActor
class ChordiSpeakViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var serverHealth: HealthResponse?
    @Published var currentTask: TaskStatus?
    @Published var chordData: ChordData?
    @Published var isUploading = false
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var selectedFileURL: URL?
    @Published var selectedFileName: String = ""
    @Published var processedAudioURL: URL?
    
    private let api = ChordiSpeakAPI()
    private var cancellables = Set<AnyCancellable>()
    private var statusTimer: Timer?
    
    init() {
        checkServerHealth()
    }
    
    deinit {
        statusTimer?.invalidate()
    }
    
    // MARK: - Server Health
    
    func checkServerHealth() {
        api.checkHealth()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.isConnected = false
                        self.errorMessage = "Server connection failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { health in
                    self.serverHealth = health
                    self.isConnected = true
                    self.errorMessage = nil
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - File Selection
    
    func selectAudioFile() {
        // This will be implemented with document picker in the view
    }
    
    // MARK: - File Upload
    
    func uploadAudio() {
        guard let fileURL = selectedFileURL else {
            errorMessage = "No file selected"
            return
        }
        
        isUploading = true
        errorMessage = nil
        
        api.uploadAudio(fileURL: fileURL, filename: selectedFileName)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isUploading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = "Upload failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { response in
                    self.startMonitoringTask(taskId: response.taskId)
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Task Monitoring
    
    private func startMonitoringTask(taskId: String) {
        isProcessing = true
        currentTask = TaskStatus(taskId: nil, status: "queued", step: "Uploaded", filename: selectedFileName, progress: 0, outputFile: nil, error: nil)
        
        // Start polling for status updates
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateTaskStatus(taskId: taskId)
        }
    }
    
    private func updateTaskStatus(taskId: String) {
        api.getTaskStatus(taskId: taskId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = "Failed to get task status: \(error.localizedDescription)"
                        self.stopMonitoring()
                    }
                },
                receiveValue: { taskStatus in
                    self.currentTask = taskStatus
                    
                    // Check if task is complete
                    if taskStatus.status == "completed" {
                        self.taskCompleted(taskId: taskId)
                    } else if taskStatus.status == "failed" {
                        self.taskFailed(taskStatus: taskStatus)
                    } else if taskStatus.status == "cancelled" {
                        self.taskCancelled()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func taskCompleted(taskId: String) {
        stopMonitoring()
        isProcessing = false
        
        // Download the processed audio
        downloadProcessedAudio(taskId: taskId)
        
        // Get chord data
        getChordData(taskId: taskId)
    }
    
    private func taskFailed(taskStatus: TaskStatus) {
        stopMonitoring()
        isProcessing = false
        errorMessage = taskStatus.error ?? "Task failed"
    }
    
    private func taskCancelled() {
        stopMonitoring()
        isProcessing = false
    }
    
    private func stopMonitoring() {
        statusTimer?.invalidate()
        statusTimer = nil
    }
    
    // MARK: - Download Processed Audio
    
    private func downloadProcessedAudio(taskId: String) {
        api.downloadAudio(taskId: taskId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = "Failed to download audio: \(error.localizedDescription)"
                    }
                },
                receiveValue: { audioData in
                    self.saveProcessedAudio(audioData: audioData)
                }
            )
            .store(in: &cancellables)
    }
    
    private func saveProcessedAudio(audioData: Data) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent("chord_vocals.mp3")
        
        do {
            try audioData.write(to: audioURL)
            processedAudioURL = audioURL
        } catch {
            errorMessage = "Failed to save audio: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Get Chord Data
    
    private func getChordData(taskId: String) {
        api.getChordData(taskId: taskId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = "Failed to get chord data: \(error.localizedDescription)"
                    }
                },
                receiveValue: { chordData in
                    self.chordData = chordData
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Cancel Task
    
    func cancelCurrentTask() {
        guard let taskId = currentTask?.taskId else { return }
        
        api.cancelTask(taskId: taskId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = "Failed to cancel task: \(error.localizedDescription)"
                    }
                },
                receiveValue: { _ in
                    self.stopMonitoring()
                    self.isProcessing = false
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Reset State
    
    func resetState() {
        currentTask = nil
        chordData = nil
        processedAudioURL = nil
        selectedFileURL = nil
        selectedFileName = ""
        errorMessage = nil
        isUploading = false
        isProcessing = false
        stopMonitoring()
    }
} 