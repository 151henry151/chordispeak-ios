import Foundation
import Combine

class ChordiSpeakAPI: ObservableObject {
    private let baseURL: String
    private let session: URLSession
    
    init(baseURL: String = "https://chordispeak-130612573310.us-east4.run.app") {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
    
    // MARK: - Health Check
    
    func checkHealth() -> AnyPublisher<HealthResponse, Error> {
        let url = URL(string: "\(baseURL)/health")!
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: HealthResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - File Upload
    
    func uploadAudio(fileURL: URL, filename: String) -> AnyPublisher<UploadResponse, Error> {
        let url = URL(string: "\(baseURL)/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            body.append(fileData)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: UploadResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Task Status
    
    func getTaskStatus(taskId: String) -> AnyPublisher<TaskStatus, Error> {
        let url = URL(string: "\(baseURL)/status/\(taskId)")!
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TaskStatus.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Download Processed Audio
    
    func downloadAudio(taskId: String) -> AnyPublisher<Data, Error> {
        let url = URL(string: "\(baseURL)/download/\(taskId)")!
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Chord Data
    
    func getChordData(taskId: String) -> AnyPublisher<ChordData, Error> {
        let url = URL(string: "\(baseURL)/chords/\(taskId)")!
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ChordData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cancel Task
    
    func cancelTask(taskId: String) -> AnyPublisher<Void, Error> {
        let url = URL(string: "\(baseURL)/cancel/\(taskId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return session.dataTaskPublisher(for: request)
            .map { _ in () }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

// MARK: - Error Handling

enum ChordiSpeakError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case taskNotFound
    case taskNotCompleted
    case fileUploadFailed
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .taskNotFound:
            return "Task not found"
        case .taskNotCompleted:
            return "Task not completed"
        case .fileUploadFailed:
            return "Failed to upload file"
        }
    }
} 