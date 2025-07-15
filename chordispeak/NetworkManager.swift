import Foundation
import Combine
import Network

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    @Published var isConnected = false
    @Published var connectionType: NWInterface.InterfaceType?
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var cancellables = Set<AnyCancellable>()
    
    // Configuration
    private let maxRetryAttempts = 3
    private let retryDelay: TimeInterval = 2.0
    private let requestTimeout: TimeInterval = 30.0
    
    init() {
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    // MARK: - Request Configuration
    
    func createSecureRequest(for url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = requestTimeout
        
        // Add security headers
        request.setValue("ChordiSpeak/1.0.0 iOS", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add app version for API compatibility checking
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue(appVersion, forHTTPHeaderField: "X-App-Version")
        }
        
        // Add device info for analytics
        request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "X-iOS-Version")
        request.setValue(UIDevice.current.modelName, forHTTPHeaderField: "X-Device-Model")
        
        return request
    }
    
    // MARK: - Secure Session Configuration
    
    var secureSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestTimeout
        configuration.timeoutIntervalForResource = 120.0
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        
        // Enable HTTP/2
        configuration.multipathServiceType = .handover
        
        // Security settings
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        configuration.urlCache = nil // Disable caching for sensitive data
        
        return URLSession(configuration: configuration)
    }
    
    // MARK: - Request with Retry Logic
    
    func performRequest<T: Decodable>(_ request: URLRequest, 
                                     type: T.Type,
                                     retryCount: Int = 0) -> AnyPublisher<T, NetworkError> {
        
        // Check network connectivity
        guard isConnected else {
            return Fail(error: NetworkError.noConnection)
                .eraseToAnyPublisher()
        }
        
        return secureSession.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response in
                // Validate response
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                // Check status code
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw NetworkError.unauthorized
                case 403:
                    throw NetworkError.forbidden
                case 404:
                    throw NetworkError.notFound
                case 429:
                    throw NetworkError.rateLimited
                case 500...599:
                    throw NetworkError.serverError(code: httpResponse.statusCode)
                default:
                    throw NetworkError.httpError(code: httpResponse.statusCode)
                }
            }
            .decode(type: type, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return NetworkError.decodingError(error)
                } else {
                    return NetworkError.unknown(error)
                }
            }
            .catch { [weak self] error -> AnyPublisher<T, NetworkError> in
                guard let self = self,
                      retryCount < self.maxRetryAttempts,
                      self.shouldRetry(error: error) else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                print("Retrying request (attempt \(retryCount + 1)/\(self.maxRetryAttempts))")
                
                return Just(())
                    .delay(for: .seconds(self.retryDelay), scheduler: DispatchQueue.main)
                    .flatMap { _ in
                        self.performRequest(request, type: type, retryCount: retryCount + 1)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Multipart Upload with Progress
    
    func uploadMultipart(url: URL,
                        fileURL: URL,
                        filename: String,
                        progressHandler: @escaping (Double) -> Void) -> AnyPublisher<UploadResponse, NetworkError> {
        
        var request = createSecureRequest(for: url, method: "POST")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            
            // Check file size
            let maxSize = 50 * 1024 * 1024 // 50MB
            guard fileData.count <= maxSize else {
                return Fail(error: NetworkError.fileTooLarge)
                    .eraseToAnyPublisher()
            }
            
            body.append(fileData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
        } catch {
            return Fail(error: NetworkError.fileReadError(error))
                .eraseToAnyPublisher()
        }
        
        // Create upload task with progress tracking
        let uploadSubject = PassthroughSubject<UploadResponse, NetworkError>()
        
        let task = secureSession.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                uploadSubject.send(completion: .failure(.unknown(error)))
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                uploadSubject.send(completion: .failure(.invalidResponse))
                return
            }
            
            do {
                let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
                uploadSubject.send(uploadResponse)
                uploadSubject.send(completion: .finished)
            } catch {
                uploadSubject.send(completion: .failure(.decodingError(error)))
            }
        }
        
        // Track upload progress
        let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                progressHandler(progress.fractionCompleted)
            }
        }
        
        task.resume()
        
        return uploadSubject
            .handleEvents(receiveCompletion: { _ in
                observation.invalidate()
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    private func shouldRetry(error: NetworkError) -> Bool {
        switch error {
        case .noConnection, .timeout, .serverError:
            return true
        case .rateLimited:
            return true // Could implement exponential backoff here
        default:
            return false
        }
    }
}

// MARK: - Network Error Types

enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(code: Int)
    case httpError(code: Int)
    case decodingError(Error)
    case fileReadError(Error)
    case fileTooLarge
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "Request timed out. Please try again."
        case .invalidResponse:
            return "Invalid response from server."
        case .unauthorized:
            return "Authentication required."
        case .forbidden:
            return "Access forbidden."
        case .notFound:
            return "Resource not found."
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .httpError(let code):
            return "HTTP error \(code)"
        case .decodingError:
            return "Failed to process server response."
        case .fileReadError:
            return "Failed to read file."
        case .fileTooLarge:
            return "File is too large. Maximum size is 50MB."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Device Model Extension

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // Map to friendly names
        switch identifier {
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        default: return identifier
        }
    }
}