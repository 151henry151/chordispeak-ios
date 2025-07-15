//
//  ContentView.swift
//  chordispeak
//
//  Created by Henry Romp on 7/14/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChordiSpeakViewModel()
    @State private var showingFilePicker = false
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Connection Status
                    connectionStatusSection
                    
                    // File Upload Section
                    if !viewModel.isProcessing && viewModel.currentTask == nil {
                        fileUploadSection
                    }
                    
                    // Processing Section
                    if viewModel.isProcessing || viewModel.currentTask != nil {
                        processingSection
                    }
                    
                    // Results Section
                    if let chordData = viewModel.chordData {
                        resultsSection(chordData: chordData)
                    }
                    
                    // Error Section
                    if let errorMessage = viewModel.errorMessage {
                        errorSection(errorMessage: errorMessage)
                    }
                }
                .padding()
            }
            .navigationTitle("ChordiSpeak")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isProcessing {
                        Button("Cancel") {
                            viewModel.cancelCurrentTask()
                        }
                        .foregroundColor(.red)
                    } else if viewModel.chordData != nil {
                        Button("New File") {
                            viewModel.resetState()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilePicker) {
            AudioFilePicker(
                selectedURL: $viewModel.selectedFileURL,
                selectedFileName: $viewModel.selectedFileName
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("ChordiSpeak")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("AI Chord Vocal Generator")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Connection Status Section
    
    private var connectionStatusSection: some View {
        HStack {
            Circle()
                .fill(viewModel.isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            
            Text(viewModel.isConnected ? "Connected to Server" : "Server Disconnected")
                .font(.subheadline)
                .foregroundColor(viewModel.isConnected ? .green : .red)
            
            Spacer()
            
            if let health = viewModel.serverHealth {
                Text("v\(health.version)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - File Upload Section
    
    private var fileUploadSection: some View {
        VStack(spacing: 16) {
            Text("Upload Audio File")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.selectedFileName.isEmpty {
                Button(action: {
                    showingFilePicker = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Select Audio File")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("MP3, WAV, FLAC, M4A (max 50MB)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                }
            } else {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.blue)
                        
                        Text(viewModel.selectedFileName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button("Change") {
                            showingFilePicker = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        viewModel.uploadAudio()
                    }) {
                        HStack {
                            if viewModel.isUploading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.up.circle")
                            }
                            
                            Text(viewModel.isUploading ? "Uploading..." : "Process Audio")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isUploading || !viewModel.isConnected)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Processing Section
    
    private var processingSection: some View {
        VStack(spacing: 20) {
            if let taskStatus = viewModel.currentTask {
                ProcessingProgressView(taskStatus: taskStatus)
                
                ProcessingStepsView(currentStep: taskStatus.step)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(16)
    }
    
    // MARK: - Results Section
    
    private func resultsSection(chordData: ChordData) -> some View {
        VStack(spacing: 20) {
            Text("Processing Complete!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            ChordSummaryView(chordData: chordData)
            
            ChordProgressionView(chordData: chordData)
            
            if let audioURL = viewModel.processedAudioURL {
                Button(action: {
                    // Share the processed audio file
                    let activityVC = UIActivityViewController(
                        activityItems: [audioURL],
                        applicationActivities: nil
                    )
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(activityVC, animated: true)
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Processed Audio")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Error Section
    
    private func errorSection(errorMessage: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.red)
            
            Spacer()
            
            Button("Dismiss") {
                viewModel.errorMessage = nil
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
