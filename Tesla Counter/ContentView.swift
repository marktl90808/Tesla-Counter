//  ContentView.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 5/1/2024.
//
// ContentView.swift iOS Developer directory.
// Tesla Counter
// Modified by Mark Leonard on 5/13/2024. Working: Sound-tada,Tesla, Images,
// Not Working yet - User provided sounds, images, override counts
// AI generated code for Tesla Counter.
// ChatGPT used for some generated code
import SwiftUI
import AVFoundation

// The main view of app.
struct ContentView: View {
    @ObservedObject var viewModel = TapCountViewModel()
    @State private var showAlert = false // Define showAlert as a @State property
    @State var currentDate: Date = Date()
    let userDefaultsKey = "Tap"
    
    @State var showUserDefaultsData = false
    @State public var dateInput = ""
    @State public var countInput = ""
    @State var userDefaultsData: [DailyCount] = []
    // Removed: @State private var showHistory = false
    
    // Initialization
    init() {
        viewModel.t = UserDefaults.standard.integer(forKey: userDefaultsKey) // Set the tapCount
        
        // Fetch count for current day from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let existingCounts = try? JSONDecoder().decode([Date: Int].self, from: data) {
            if let countForToday = existingCounts[currentDate] {
                viewModel.t = countForToday
            }
        }
    }

    //MARK: Not in Chat GPT code ->
    var numberOfEntries: Int { return userDefaultsData.count }
    
    @State var currentImageIndex = 0
    
    @State public var storedCounts: [Date: Int] = [:]
    @State public var overrideCount: String = ""
    
    // Audio players for sound effects
    @State var iS_O: Bool = true
    @State var player: AVAudioPlayer?
    @State var teslaPlayer: AVAudioPlayer?
    @State var tadaPlayer: AVAudioPlayer?
    @State var oopsPlayer: AVAudioPlayer?
    @State var dingPlayer: AVAudioPlayer?
    
    @State private var showSplash: Bool = true
    
    
    func updateCountForDate(_ date: Date, count: Int) {
// Retrieve existing data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           var existingCounts = try? JSONDecoder().decode([Date: Int].self, from: data) {
// Update count for the specified date
            existingCounts[date] = count
            
// Save the updated data back to UserDefaults
            if let encodedCounts = try? JSONEncoder().encode(existingCounts) {
                UserDefaults.standard.set(encodedCounts, forKey: userDefaultsKey)
            }
        }
    }
    
    let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    func saveOverrideCount() {
        if let newCount = Int(overrideCount) {
            UserDefaults.standard.set(newCount, forKey: userDefaultsKey)
            viewModel.t = newCount
            viewModel.saveCounts()
        }
    }
    func storeCount(for date: Date, count: Int) {
        storedCounts[date] = count
    }
    func playSound(soundName: String) {
        guard iS_O else { return }
        // Try common extensions and locations (with and without Sounds subdirectory)
        let extensions = ["mp3", "mpg"]
        var foundURL: URL? = nil
        for ext in extensions {
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext, subdirectory: "Sounds") {
                foundURL = url
                break
            }
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                foundURL = url
                break
            }
        }
        guard let url = foundURL else {
            print("Sound file not found: \(soundName) with extensions .mp3/.mpg")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func playSound(for tapCount: Int) {
        guard iS_O else { return }
        let soundName = viewModel.t % 10 == 0 ? "tada" : "Tesla"
        print("The count is \(viewModel.t) so I'm Playing sound: \(soundName)")
        let extensions = ["mp3", "mpg"]
        var foundURL: URL? = nil
        for ext in extensions {
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext, subdirectory: "Sounds") {
                foundURL = url
                break
            }
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                foundURL = url
                break
            }
        }
        guard let url = foundURL else {
            print("Error sound: file not found for \(soundName) with extensions .mp3/.mpg")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error sound: \(error.localizedDescription)")
        }
    }
    
    func toggleSound() {
        iS_O.toggle()
    }
    
    //    MARK: var body: some View
    var body: some View {
        
        ZStack {
            NavigationStack {
                VStack {
                    
                    Image("teslaLogo")
                        .resizable().aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            playSound(soundName: "ding")
                        }
                    // MARK: the override sheet
       
                    // MARK: after the override sheet
                                    Image("tc.\(currentImageIndex)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .onTapGesture {
                                            viewModel.incrementCountForToday()
                                            if viewModel.t.isMultiple(of: 10) {
                                                playSound(soundName: "tada")
                                            } else {
                                                playSound(soundName: "Tesla")
                                            }
                                            currentImageIndex = (currentImageIndex + 1) % 19
                                            UserDefaults.standard.set(viewModel.t, forKey: "Tap")
                                            storeCount(for: currentDate, count: viewModel.t)
                                            viewModel.saveCounts()
                                        }
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(iS_O ? " 🔈 ON " : " 🔇 Off") {
                                        toggleSound()
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(iS_O ? .green : .red)
                                    Spacer()
                                    Button(action: {
                                        viewModel.incrementCTForToday()
                                        playSound(soundName: "Cybertruck")
                                    }) {
                                        Image("ct")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 64, height: 64)
                                    }
                                    .accessibilityLabel("Add CT")
                                    .buttonStyle(.plain)
                                    Spacer()
                                    Text("Oops").foregroundColor(.red)
                                        .onTapGesture {
                                            playSound(soundName: "oops")
                                            viewModel.decrementCountForToday()
                                            print("Teslas: \(viewModel.t)")
                                        }
                                    Spacer()
                                }
                
    // Footer with tap count and buttons
                HStack {
                    Spacer()
                    Text("Teslas: \(viewModel.t)")
                        .onTapGesture {
                            playSound(soundName: "ding")
                            viewModel.saveCounts()
                            showAlert = true
                        }
                        .foregroundColor(.red)
    //                    .padding(1)
                        Spacer()
                    Text("CT: \(viewModel.ct)")
                        .foregroundColor(.green)
    //                    .padding(1)
                    Spacer()
                    NavigationLink("History") {
                        CountHistoryView(viewModel: viewModel)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
    //                .padding(0)
                        Spacer()
                }
            }
    //        Removed navigationDestination block here:
    //        .navigationDestination(isPresented: $showHistory) {
    //            CountHistoryView(viewModel: viewModel)
    //        }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Success"), message: Text("The UserDefaults data was updated."), dismissButton: .default(Text("OK")))
            }
            
            // Splash overlay
            if showSplash {
                Color(.systemBackground)
                    .ignoresSafeArea()
                Image("tc.0")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400)
                    .padding()
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.loadCounts()
            // Dismiss splash after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}
                
//                // MARK: after the override sheet



extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Preview for the ContentView.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

