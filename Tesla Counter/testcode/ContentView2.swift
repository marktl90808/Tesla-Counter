//
//  ContentView2.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 5/14/2026.
//


// ContentView2.swift
// Tesla Counter
// Refactored for Xcode 15

// ContentView2.swift
// Tesla Counter

import SwiftUI
import AVFoundation

struct ContentView2: View {
    @StateObject private var viewModel = TapCountViewModel()
    
    @State private var showAlert = false
    @State private var currentImageIndex = 0
    @State private var isSoundEnabled = true
    
    @State private var audioPlayer: AVAudioPlayer?
    // Added for Siri Voice
    @State private var speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Image("TeslaLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .onTapGesture {
                        triggerSound(name: "ding")
                    }

                // Main Tesla Image
                Image("tc.\(currentImageIndex)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 380)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .onTapGesture {
                        handleTeslaTap()
                    }

                // Cybertruck Section
                VStack(spacing: 5) {
                    Text("Cybertrucks: \(viewModel.ct)")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Image("tc.6")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
//                        .onTapGesture {
//                            handleCybertruckTap()
//                        }
                }
                .padding(.vertical, 5)

                Spacer()

                HStack {
                    Spacer()
                    Button(action: { isSoundEnabled.toggle() }) {
                        Image(systemName: isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Text("Oops")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.red)
                        .cornerRadius(12)
                        .onTapGesture {
                            triggerSound(name: "oops")
                            viewModel.decrementCountForToday()
                        }
                    Spacer()
                }

                HStack(spacing: 15) {
                    Text("Teslas: \(viewModel.t)")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.red)
                        .onTapGesture {
                            triggerSound(name: "ding")
                            viewModel.saveCounts()
                            showAlert = true
                        }

                    Button("Reset") {
                        viewModel.resetCountForToday()
                    }
                    .foregroundColor(.secondary)

                    NavigationLink(destination: CountHistoryView(viewModel: viewModel)) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                    }
                }
                .padding(.bottom, 15)
            }
        }
        .alert("Success", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Counts saved successfully.")
        }
    }

    private func handleTeslaTap() {
        viewModel.incrementCountForToday()
        let sound = viewModel.t.isMultiple(of: 10) ? "tada" : "Tesla"
        triggerSound(name: sound)
        currentImageIndex = (currentImageIndex + 1) % 19
    }

//    private func handleCybertruckTap() {
//        viewModel.incrementCybertruck()
//        
//        // Check if sound is enabled before speaking
//        guard isSoundEnabled else { return }
//        
//        // 1. Setup the speech content
//        let utterance = AVSpeechUtterance(string: "Cybertruck!")
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//        utterance.rate = 0.5 // Adjust speed (0.0 to 1.0)
//        
//        // 2. Interrupt any current speech so it triggers immediately on every tap
//        if speechSynthesizer.isSpeaking {
//            speechSynthesizer.stopSpeaking(at: .immediate)
//        }
//        
//        // 3. Speak! (Notice triggerSound is NOT called here anymore)
//        speechSynthesizer.speak(utterance)
//    }
    
    private func triggerSound(name: String) {
        guard isSoundEnabled else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        let url = Bundle.main.url(forResource: name, withExtension: "mp3") ??
                  Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "Sounds")

        if let soundURL = url {
            audioPlayer = try? AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        }
    }
}

// MARK: - Preview
struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
