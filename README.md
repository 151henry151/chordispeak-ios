# ChordiSpeak iOS App

This is the iOS frontend for the ChordiSpeak AI Chord Vocal Generator. The app allows users to upload audio files and process them through the ChordiSpeak backend to generate vocal tracks that speak the chord names in the original singer's voice.

## Features

- **Audio File Upload**: Support for MP3, WAV, FLAC, and M4A files up to 50MB
- **Real-time Processing Status**: Live progress tracking with detailed step-by-step updates
- **Chord Progression Display**: Visual timeline of detected chords with confidence scores
- **Chord Summary**: Overview of chord frequency and types
- **Processed Audio Download**: Download and share the generated chord vocal track
- **Server Health Monitoring**: Connection status and version information

## Setup Instructions

### 1. Backend Setup

The ChordiSpeak backend is already running on Google Cloud Platform:

**Production Server**: `https://chordispeak-130612573310.us-east4.run.app`

The iOS app is configured to connect to this production server by default. No local setup is required.

### 2. iOS App Setup

1. Open the project in Xcode
2. Add the new Swift files to the project:
   - `Models.swift`
   - `ChordiSpeakAPI.swift`
   - `ChordiSpeakViewModel.swift`
   - `AudioFilePicker.swift`
   - `ProcessingProgressView.swift`
   - `ChordProgressionView.swift`

3. Configure network permissions:
   - In Xcode, select your target
   - Go to "Info" tab
   - Add the following keys to your Info.plist:
     - `NSAppTransportSecurity` (Dictionary)
       - `NSAllowsArbitraryLoads` (Boolean) = `YES`
     - `NSDocumentsFolderUsageDescription` (String) = "This app needs access to documents to save processed audio files"

4. Server Configuration:
   - The app is already configured to connect to the production server
   - Server URL: `https://chordispeak-130612573310.us-east4.run.app`
   - If you need to change the server URL, modify the `baseURL` in `ChordiSpeakAPI.swift`

### 3. Build and Run

1. Connect your iOS device or use the simulator
2. Build and run the project in Xcode
3. The app will automatically check server connectivity on launch

## Usage

1. **Upload Audio**: Tap "Select Audio File" to choose an audio file from your device
2. **Process Audio**: Tap "Process Audio" to upload and begin processing
3. **Monitor Progress**: Watch the real-time progress as the AI processes your audio:
   - Audio Preparation
   - Vocal Separation (10-15 minutes)
   - Voice Sample Extraction
   - Chord Detection (2-3 minutes)
   - TTS Synthesis (15-18 seconds per chord)
   - Audio Mixing
4. **View Results**: Once complete, view the chord progression and download the processed audio
5. **Share Audio**: Use the share button to export the processed audio file

## Architecture

### Models (`Models.swift`)
- `UploadResponse`: API response for file uploads
- `TaskStatus`: Current processing status and progress
- `ChordData` & `Chord`: Chord progression data
- `HealthResponse`: Server health information
- `TaskState` & `ProcessingStep`: Enums for state management

### API Layer (`ChordiSpeakAPI.swift`)
- RESTful API client for backend communication
- File upload with multipart/form-data
- Real-time status polling
- Error handling and response parsing

### View Model (`ChordiSpeakViewModel.swift`)
- Business logic and state management
- File selection and upload coordination
- Progress monitoring and status updates
- Audio file management

### UI Components
- `AudioFilePicker`: Document picker for audio files
- `ProcessingProgressView`: Animated progress display
- `ChordProgressionView`: Timeline visualization of chords
- `ContentView`: Main app interface

## API Endpoints

The app communicates with these backend endpoints:

- `GET /health` - Server health check
- `POST /upload` - Upload audio file
- `GET /status/<task_id>` - Get processing status
- `GET /download/<task_id>` - Download processed audio
- `GET /chords/<task_id>` - Get chord progression data
- `POST /cancel/<task_id>` - Cancel processing task

## Supported Audio Formats

- MP3
- WAV
- FLAC
- M4A

Maximum file size: 50MB

## Processing Time

- **3-4 minute songs**: ~5-10 minutes total processing time
- **Vocal separation**: 10-15 minutes (most time-consuming)
- **Chord detection**: 2-3 minutes
- **TTS synthesis**: 15-18 seconds per unique chord

## Troubleshooting

### Connection Issues
- The app connects to the production server at `https://chordispeak-130612573310.us-east4.run.app`
- Check that the `baseURL` in `ChordiSpeakAPI.swift` is correct
- Verify network permissions in Info.plist
- Ensure your device has internet connectivity

### File Upload Issues
- Check file size (max 50MB)
- Ensure file format is supported
- Verify document folder permissions

### Processing Issues
- Monitor server logs for detailed error information
- Check available memory (8GB+ recommended for backend)
- Ensure GPU is available for faster processing

## Development Notes

- The app uses Combine for reactive programming
- SwiftUI for modern iOS UI development
- URLSession for network requests
- Document picker for file selection
- Real-time progress updates via polling

## License

This project is licensed under the GNU General Public License v3.0, matching the backend license. 