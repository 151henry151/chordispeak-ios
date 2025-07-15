import SwiftUI
import UniformTypeIdentifiers

struct AudioFilePicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Binding var selectedFileName: String
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [
            .mp3,
            .wav,
            .audio,
            .mpeg4Audio
        ]
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: AudioFilePicker
        
        init(_ parent: AudioFilePicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
            
            defer {
                if shouldStopAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Copy the file to a temporary location
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let tempURL = documentsPath.appendingPathComponent(url.lastPathComponent)
            
            do {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: url, to: tempURL)
                
                DispatchQueue.main.async {
                    self.parent.selectedURL = tempURL
                    self.parent.selectedFileName = url.lastPathComponent
                }
            } catch {
                print("Error copying file: \(error)")
            }
        }
    }
} 