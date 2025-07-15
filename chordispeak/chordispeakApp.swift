//
//  chordispeakApp.swift
//  chordispeak
//
//  Created by Arum Vonn Wildflower on 7/14/25.
//

import SwiftUI
import AVFoundation
import UserNotifications

@main
struct chordispeakApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var networkManager = NetworkManager.shared
    
    init() {
        setupAudioSession()
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .environmentObject(networkManager)
                } else {
                    OnboardingView()
                }
            }
            .onAppear {
                // Request notification permissions if needed
                requestNotificationPermissions()
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, 
                                                           mode: .default,
                                                           options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupAppearance() {
        // Configure global appearance
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted")
            }
        }
    }
}
